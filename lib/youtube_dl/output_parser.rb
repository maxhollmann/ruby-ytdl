require 'filesize'
require 'youtube_dl/state'

module YoutubeDL
  class OutputParser
    def initialize
      @state = State.new
    end

    attr_reader :state

    def process(line)
      line = line.strip

      m = regex.match(line)
      return :unparsable if m.nil?

      if m[:destination]
        state.destination = Pathname(m[:destination])
        return :destination
      end

      if m[:merger]
        state.destination = Pathname(m[:merger])
        return :merger
      end

      if m[:deleting]
        return :deleting
      end

      if m[:info_json]
        state.info_json = Pathname(m[:info_json]) if m[:info_json]
        return :info_json
      end

      if m[:progress]
        if m[:progress]
          if m[:progress] == '100'
            state.progress = 100
          else
            state.progress = m[:progress].to_f
          end
        end
        state.total_size = Filesize.from("#{m[:total_size]} #{m[:total_size_unit]}") if m[:total_size]
        state.speed = Filesize.from("#{m[:speed]} #{m[:speed_unit]}") if m[:speed]
        return :progress
      end

      if m[:error]
        state.error = m[:error] if m[:error]
        return :error
      end

      raise 'Not sure how I got here...'
    end

    private

    def regex
      %r{
        #{progress_regex} |
        #{destination_regex} |
        #{existing_destination_regex} |
        #{merger_regex} |
        #{deletion_regex} | 
        #{info_json_regex} |
        #{error_regex}
      }x
    end

    def progress_regex
      %r{
        \[download\] \s+
        #{num_regex('progress')}%
        (
          \s+ of \s+
          #{num_with_unit_regex('total_size')}
          (
            \s+ at \s+
            #{num_with_unit_regex('speed')}
          )?
        )?
      }x
    end

    def destination_regex
      %r{
        \[download\] \s+ Destination: \s+
        (?<destination>.*)
      }x
    end

    def existing_destination_regex
      %r{
        \[download\] \s
        (?<destination>.*?) \s
        has \s already \s been \s downloaded
      }x
    end

    def merger_regex
      %r{
        \[Merger\] \s+ Merging \s+ formats \s+ into \s+
        "(?<merger>[^"]+)"
      }x
    end

    def deletion_regex
      %r{
        Deleting \s+ original \s+ file \s+
        (?<deleting>.*)
      }x
    end

    def info_json_regex
      %r{
        \[info\] \s Writing \s video .*? \s metadata \s as \s JSON \s to: \s
        (?<info_json>.*)
      }x
    end

    def error_regex
      %r{
        (
          ERROR: \s
          (?<error>.*)
        ) | (?<error>
          .*: \s not \s found
        )
      }x
    end

    def num_regex(name)
      %r{
        (?<#{name}>
          \d+(\.\d+)?
        )
      }x
    end

    def unit_regex(name)
      %r{
        (?<#{name}_unit>
          \w+
        )
      }x
    end

    def num_with_unit_regex(name)
      %r{
        #{num_regex(name)}
        #{unit_regex(name)}
      }x
    end
  end
end
