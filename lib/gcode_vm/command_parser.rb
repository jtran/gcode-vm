module GcodeVm
  class CommandParser

    def parse(gcode, line_separator: $/)
      # GCode spec allows carriage return, line feed, or both for line endings.
      gcode.each_line(line_separator).lazy
        .map {|s| s.chomp("\n").chomp("\r") }
        .map(&:parse_line)
    end

    def parse_line(line)
      orig_line = line
      comments = []
      # Extract semicolon comment.
      match = /;(.*)\z/.match(line)
      if match
        comments << $1
        line = line[0...match.begin(0)]
      end
      # Extract parentheses comment.  There could be many.
      begin
        match = /\(([^\(]*?)\)/.match(line)
        if match
          comments << $1
          line = line[0...match.begin(0)] + line [match.end(0)..-1]
        end
      end while match

      # If there's nothing on the line besides comments, we're done.
      if line.blank? && comments.present?
        return Commands::Comment.new(comment: comments.join(' / '), gcode: orig_line)
      end

      params = {}
      command_word = nil
      # Strip prevents a leading result that's blank, which would affect the
      # index.
      words = line.strip.split(/\s+/)
      # Each command could start with /N\d+/ for a line number.
      line_number = nil
      words.each_with_index do |word, i|
        if i == 0 && /N(\d+)/ =~ word
          line_number = $1.to_i
        elsif ! line_number && i == 0 || line_number && i == 1
          command_word = word
        else
          parsed = parse_word(word)
          next unless parsed

          key, val = parsed
          params[key] = val
        end
      end

      single_comment = comments.present? ? comments.join(' / ') : nil

      # Build a Command instance.
      kwargs = {
        line_number: line_number,
        comment: single_comment,
        gcode: orig_line,
      }
      cmd = case command_word
      when 'G0', 'G1'
        rapid = command_word == 'G0'
        Commands::Move.new(axes: params, rapid: rapid, **kwargs)
      when 'G2', 'G3'
        ccw = command_word == 'G3'
        Commands::Arc.new(axes: params, ccw: ccw, **kwargs)
      when 'G4'
        Commands::Dwell.new(words: params, **kwargs)
      when 'G28'
        Commands::Home.new(axes: params, **kwargs)
      when 'G90'
        Commands::Absolute.new(**kwargs)
      when 'G91'
        Commands::Incremental.new(**kwargs)
      when 'G92'
        Commands::SetPosition.new(axes: params, **kwargs)
      else
        # We weren't able to determine what kind of command it was.
        Commands::Unknown.new(**kwargs)
      end

      cmd
    end


    private

    def parse_word(word)
      match = /\A([A-Za-z]+)([\de\.\+\-]*)\z/.match(word)
      return nil if ! match

      key = $1
      number = $2

      if number.nil? || number.length == 0
        value = nil
      elsif number =~ /\A\d+\z/
        value = number.to_i
      else
        value = number.to_f
      end

      [key, value]
    end

  end
end
