# keyleds.cr

A Crystal interface to the [`libkeyleds`](https://github.com/keyleds/keyleds) library.

## License

As a derived work of `keyleds`, these bindings are licensed under the GNU GPLv3.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     keyleds:
       github: nickbclifford/keyleds.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "keyleds"

APP_ID = 1_u8

Keyleds::Device.open("/dev/hidraw1", APP_ID) do |device|
  puts device.name

  device.set_led_block(:logo, red: 0, blue: 255, green: 0)
  device.commit_leds
end
```

## Contributing

1. Fork it (<https://github.com/nickbclifford/keyleds.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Nick Clifford](https://github.com/nickbclifford) - creator and maintainer
