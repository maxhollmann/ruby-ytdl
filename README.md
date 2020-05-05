# ytdl

A Ruby wrapper for youtube-dl with progress callbacks.

## Installation

```shell
gem install ytdl
```

```ruby
gem 'ytdl'
```

Make sure you have [youtube-dl](https://github.com/ytdl-org/youtube-dl) installed and available in your `PATH`. If you have `pip` installed:

```shell
pip install youtube-dl
```

## Usage

Minimal example:

```ruby
YoutubeDL.download('https://www.youtube.com/watch?v=MmIWve5bUpU').call
```

With callbacks and options:

```ruby
state = YoutubeDL.download('https://www.youtube.com/watch?v=MmIWve5bUpU', format: 'mp4')
  .on_progress do |state:, line:|
    puts "Progress: #{state.progress}%"
  end
  .on_error do |state:, line:|
    puts "Error: #{state.error}"
  end
  .on_complete do |state:, line:|
    puts "Complete: #{state.destination}"
  end
  .call
```

`YoutubeDL.download` returns the state after `youtube-dl` has exited. If the download was successful, `state.info_json` is loaded into `state.info` and the `info_json` file deleted.

### Events

One event is emitted for each line printed by `youtube-dl`.

The full list of events types is:

* `unparsable`: The `OutputParser` couldn't parse the line
* `destination`: Download destination announcement (stored in `state.destination`)
* `info_json`: Info JSON destination announcement (stored in `state.info_json`)
* `progress`: Download progress in percentage (stored in `state.progress`)
* `error`: An error message (stored in `state.error` without the `ERROR: ` prefix)
* `complete`: The download is complete (Info JSON is parsed into `state.info` and deleted, `state.destination` now exists)
* `unclear_exit_state`: `youtube-dl` exited without error, but either `destination` or `info_json` does not exist

### Options

Options passed to `YoutubeDL.download` get transformed as follows:

* `some_option: true` becomes `--some-option`
* `some_option: false` becomes `--no-some-option`
* `some_option: 'anything'` becomes `--some-option anything`
* `some_option: nil` can be used to remove a default option
