require 'pty'
require 'youtube_dl/listener'
require 'youtube_dl/output_parser'

module YoutubeDL
  class Runner
    def initialize(command, listener: Listener.new)
      @command = command
      @listener = listener
    end

    def call
      parser = OutputParser.new
      run(command: @command, parser: parser)

      if parser.state.complete?
        parser.state.load_and_delete_info_json
        @listener.call(:complete, state: parser.state)
      elsif parser.state.error?
        @listener.call(:error, state: parser.state)
      else
        @listener.call(:unclear_exit_state, state: parser.state)
      end

      parser.state
    end

    def on(event, &block)
      @listener.register(event, &block)
      self
    end

    def respond_to_missing?(method, *)
      method.to_s.start_with?('on_') || super
    end

    def method_missing(method, &block)
      return super unless method.to_s.start_with?('on_')

      event = method.to_s.sub(/^on_/, '').to_sym
      on(event, &block)
    end

    private

    def run(command:, parser:)
      PTY.spawn(command.to_s) do |stdout, stdin, pid|
        begin
          stdout.each do |line|
            type = parser.process(line)
            @listener.call(type, state: parser.state, line: line)
          end
        rescue Errno::EIO
        end
      end
    end
  end
end
