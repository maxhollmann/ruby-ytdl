require 'json'

module YoutubeDL
  class State
    attr_accessor(
      :progress,
      :destination,
      :total_size,
      :speed,
      :error,
      :info_json,
      :info,
    )

    def error?
      !error.nil?
    end

    def complete?
      destination&.exist? && (info || info_json&.exist?)
    end

    def load_and_delete_info_json
      self.info = JSON.parse(info_json.read())
      info_json.unlink()
    end
  end
end
