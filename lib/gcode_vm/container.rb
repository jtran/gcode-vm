module GcodeVm
  # Dependency injection container that instantiates and caches objects.
  class Container

    def initialize
      @cache = {}
      @factories = {}
    end

    # Registers a factory for a given name.  Instantiating the factory must not
    # result in nil.
    def register(name, factory: nil, &block)
      name = normalize_name(name)

      if @factories.has_key?(name)
        raise ArgumentError.new("You tried to re-register a name that already has a factory registered: #{name.inspect}")
      end

      factory ||= block
      @factories[name] = factory

      self
    end

    # Get the factory that was registered for the given name.
    def factory_for(name)
      @factories[normalize_name(name)]
    end

    # Lookup the instance registered with the given name.  If the name hasn't
    # been looked up before, it will be instantiated from the factory.  The
    # result will be cached for subsequent calls.  Instantiated values are
    # treated as singletons for a given container.
    def lookup(name)
      name = normalize_name(name)

      # Return a cached result if we have one.
      if @cache.has_key?(name)
        return @cache[name]
      end

      factory = factory_for(name)
      if factory.nil?
        return nil
      end

      value = instantiate(factory)

      # Cache the result.
      @cache[name] = value

      value
    end

    # @return [Boolean] true if an instance has been cached for the given name.
    def cached?(name)
      @cache.has_key?(normalize_name(name))
    end

    # Instantiates an instance for the given factory.
    def instantiate(factory)
      case factory
      when Class
        factory.new
      else
        factory.call
      end
    end

    # Given a name, convert it to its normal form.
    def normalize_name(name)
      # Convert to Symbol.
      if name.respond_to?(:to_sym)
        name = name.to_sym
      end

      name
    end

  end
end
