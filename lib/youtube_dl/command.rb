require 'shellwords'
require 'dry/configurable'

module YoutubeDL
  class Command
    extend Dry::Configurable

    def config
      self.class.config
    end

    setting :executable, 'youtube-dl'
    setting :default_options, {}
    setting :forced_options, {
      newline: true,
      color: false,
      write_info_json: true,
      playlist: false,
    }

    def initialize(url, **options)
      @url = url
      @options =
        config.default_options
        .merge(options)
        .merge(config.forced_options)
    end

    def arguments
      @options.flat_map do |option, value|
        option = option.to_s.gsub('_', '-')
        case value
        when [] then nil
        when true then "--#{option}"
        when false then "--no-#{option}"
        else ["--#{option}", value]
        end
      end
    end

    def to_a
      [config.executable] + arguments + [@url]
    end

    def to_s
      Shellwords.join(to_a)
    end
  end
end
