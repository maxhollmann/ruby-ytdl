module YoutubeDL
  class Listener
    def initialize
      @callbacks = Hash.new { |h, k| h[k] = [] }
    end

    def call(event, state:, line: nil)
      (@callbacks[event] + @callbacks[:any]).each do |cb|
        cb.call(state: state, line: line)
      end
    end

    def register(event, &block)
      @callbacks[event] << block
    end
  end
end
