module GcodeVm
  # Loads transforms from a transform spec file.
  #
  # The following keys are used for other purposes and shouldn't be used by
  # individual transform implementations as fields.
  #
  # - `comment` stripped from arguments and ignored
  # - `id` used to reference a transform
  # - `if` used to conditionally execute a transform
  # - `unless` used to conditionally execute a transform
  # - `ui_metadata` stripped from arguments and ignored
  module TransformSpec
    extend self

    # Given a transform spec YAML file, instantiate the transform objects.  The
    # result of this can be piped using TransformingEnumerator#pipe.
    #
    # @param container [Container] dependency injection container
    # @return [Array<Transformer, TransformingEnumerator>]
    def load_file(filename,
                  container:,
                  transforms_by_id: {},
                  allow_unsafe: false,
                  unsafe_error: nil)
      transform_doc = parse(filename, allow_unsafe: allow_unsafe)

      load(transform_doc[:transform],
           container: container,
           transforms_by_id: transforms_by_id,
           allow_unsafe: allow_unsafe,
           unsafe_error: unsafe_error)
    end

    # Parse a transform file's YAML.  This is mostly used for debugging YAML
    # files.
    #
    # @return [ActiveSupport::HashWithIndifferentAccess]
    def parse(filename, allow_unsafe: false)
      if filename
        yaml = File.read(filename)
        if allow_unsafe
          transform_doc = YAML.load(yaml, filename)
        else
          transform_doc = YAML.safe_load(yaml, [], [], false, filename)
        end
      else
        # If no filename was given, return an empty doc.
        transform_doc = {}
      end
      if transform_doc.respond_to?(:with_indifferent_access)
        transform_doc = transform_doc.with_indifferent_access
      end

      transform_doc
    end

    # Given a transform spec, instantiate the transform objects that they
    # represent.
    #
    # @param container [Container] dependency injection container
    # @return [Array<Transformer, TransformingEnumerator>]
    def load(specs,
             container:,
             transforms_by_id: {},
             allow_unsafe: false,
             unsafe_error: nil)
      Array.wrap(specs).map {|spec|
        case spec
        when String
          transform_name = spec
          opts = {}
        when Hash
          opts = spec.symbolize_keys
          transform_name = opts.delete(:name)
        end
        klass = lookup_transform_class(transform_name)

        if ! allow_unsafe && klass.respond_to?(:unsafe)
          if unsafe_error
            unsafe_error.call(transform_name)
            next
          else
            raise "You tried to load an unsafe transform, but didn't explicitly allow: #{transform_name}"
          end
        end

        # Extract ID.
        transform_id = opts.delete(:id)

        # Strip comment.
        opts.delete(:comment)

        # Strip UI metadata.
        opts.delete(:ui_metadata)

        # Extract conditional options.
        condition = extract_conditions(opts)

        # Move condition back into keyword arguments if the class supports it.
        if condition && can_instantiate_with_condition?(klass)
          opts[:condition] = condition
          # Don't use this anymore.
          condition = nil
        end

        transform = orig_transform = instantiate_transform(klass, opts, container)

        # Wrap with the conditional if it's a Transformer.
        if condition
          if ! transform.respond_to?(:call)
            raise "You tried to use a condition like \"if\" or \"unless\" with a stream transform that doesn't support it yet: #{transform_name}"
          end
          transform = ConditionalTransformer.new(condition: condition,
                                                 transformer: transform)
        end

        # Store in map by ID only after we've made it past all other checks.
        if transform_id
          transforms_by_id[transform_id.to_s] = orig_transform
        end

        transform
      }
    end

    # Given a Class, a Hash of keyword arguments, and a {Container}, instantiate
    # it and return the instance.
    def instantiate_transform(klass, opts, container)
      # Inject dependencies.
      dep_names = Array.wrap(klass.try(:needs))
      dep_names.each do |dep_name|
        # We need a Symbol.
        dep_name = container.normalize_name(dep_name).to_sym
        # If the options already explicitly has this dependency, don't try to
        # inject it.
        next if opts.has_key?(dep_name)

        value = if dep_name == :container
            # Use the container itself.
            container
          else
            container.lookup(dep_name)
          end
        if value.nil?
          raise "Unknown dependency specified by class: dep_name=#{dep_name.inspect} klass=#{klass}; did you forget to register it in the container?"
        end

        # Add the value to the keyword arguments.
        opts[dep_name] = value
      end

      # Instantiate the transform.
      transform = opts.blank? ? klass.new : klass.new(**opts)

      transform
    end

    def extract_conditions(options)
      conditions = []
      if options.has_key?(:if)
        str_cond = options.delete(:if)
        cond = Condition.parse(str_cond)
        conditions << cond
      end
      if options.has_key?(:unless)
        str_cond = options.delete(:unless)
        cond = Condition.parse(str_cond)
        cond = GcodeVm::NotCondition.new(condition: cond)
        conditions << cond
      end

      case conditions.size
      when 0
        nil
      when 1
        conditions.first
      else
        GcodeVm::AndCondition.new(conditions: conditions)
      end
    end

    def lookup_transform_class(name)
      root = name.camelize
      class_name = nil
      %w[Transformer Enumerator].find {|suffix|
        s = "#{root}#{suffix}"
        if GcodeVm.const_defined?(s, false)
          class_name = s
          true
        else
          false
        end
      }
      if ! class_name
        raise "Transformer not found: #{name}"
      end

      GcodeVm.const_get(class_name, false)
    end

    # Returns an array of transform names that can be looked up.
    def transform_names
      GcodeVm.constants(false).map(&:to_s)
        .grep(/Transformer$|Enumerator$/)
        .reject {|s| s == 'TransformingEnumerator' }
        .reject {|s| s == 'MultiAxisTransformer' }
        .map {|s| s.sub(/Transformer$|Enumerator$/, '') }
        .map(&:underscore)
        .sort
    end

    # If it's a string, try to parse it as a Regexp.  But don't convert it if
    # it's something else besides a string.
    def maybe_regexp(value)
      if ! value.respond_to?(:to_str)
        return value
      end

      regexp = parse_regexp(value.to_str)
      regexp ? regexp : value
    end

    # Given a string, parses it as a Regexp without using eval.
    #
    # The implementation is based off of the Psych YAML parser.
    # https://github.com/ruby/psych/blob/master/lib/psych/visitors/to_ruby.rb
    #
    # People could just type this in their YAML files:
    #
    #     !ruby/regexp /[A-Z]*/
    #
    # But that would tie their file to the Ruby implementation, and it would just
    # be less convenient.
    def parse_regexp(str)
      if str !~ /^\/(.*)\/([mixn]*)$/m
        return nil
      end

      source = $1
      options = 0
      lang = nil
      ($2 || '').split('').each do |option|
        case option
        when 'x'
          options |= Regexp::EXTENDED
        when 'i'
          options |= Regexp::IGNORECASE
        when 'm'
          options |= Regexp::MULTILINE
        when 'n'
          options |= Regexp::NOENCODING
        else
          lang = option
        end
      end

      Regexp.new(*[source, options, lang].compact)
    end


    private

    def can_instantiate_with_condition?(klass)
      method = klass.instance_method(:initialize)

      # If a class's #initialize has a `condition:` keyword parameter, treat
      # this as the condition.
      method.parameters.any? {|t, name|
        name == :condition
      }
    end

  end
end
