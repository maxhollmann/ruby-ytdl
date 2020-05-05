require 'youtube_dl/runner'
require 'youtube_dl/command'

module YoutubeDL
  def self.download(url, **options)
    Runner.new(Command.new(url, **options))
  end
end
