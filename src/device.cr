require "bit_array"

require "./bridge"
require "./error"
require "./libkeyleds"

# Represents a physical Logitech device that can be interfaced with.
class Keyleds::Device
  # The full range of valid application IDs that can be used for initialization (i.e. `Device.open`.)
  APP_IDS = LibKeyleds::APP_ID_MIN..LibKeyleds::APP_ID_MAX

  # For GC purposes, see `Device#on_gkey`
  @cb : Pointer(Void)?

  @device : LibKeyleds::Keyleds

  # Creates a new `Device` with the given parameters, yields it to a block, and automatically closes the device.
  def self.open(path : String, app_id : UInt8)
    dev = new(path, app_id)
    begin
      yield dev
    ensure
      dev.close
    end
  end

  # Creates a new `Device`. Must be explicitly closed with `Device#close` after usage.
  #
  # - `path` must be a valid path to the device's corresponding HID file (i.e. `/dev/hidraw1`).
  # - `app_id` is a constant identifier for use with all further device communication. See `APP_IDS` for valid arguments.
  def initialize(path : String, app_id : UInt8)
    unless APP_IDS.includes?(app_id)
      raise ArgumentError.new("app id must be between #{APP_IDS.begin} and #{APP_IDS.end}")
    end

    # error state indicated by null pointer
    unless @device = LibKeyleds.open(path, app_id)
      raise Error.from_lib
    end
  end

  # Closes the device handle.
  def close
    LibKeyleds.close(@device)
  end

  # Gets all device LED `Keyblock`s.
  def blocks : Array(Keyblock)
    try(get_block_info, out ptr)
    # VLA hackery, see comment in libkeyleds.cr
    data_ptr = (ptr.as(UInt8*) + offsetof(LibKeyleds::KeyblocksInfo, @blocks)).as(Keyblock*)
    Slice.new(data_ptr, ptr.value.length).to_a
  end

  # Applies pending lighting changes set by `Device#set_leds` or `Device#set_led_block`.
  def commit_leds
    try(commit_leds)
  end

  # Enables or disable custom G-key behavior. If `false`, G-keys will default to their corresponding F-keys.
  def custom_gkeys(enabled : Bool)
    try(gkeys_enable, enabled)
  end

  # Returns the device's underlying file descriptor.
  def fd : IO::FileDescriptor
    IO::FileDescriptor.new(LibKeyleds.device_fd(@device))
  end

  # Gets the number of HID++ features supported by the device.
  def feature_count : UInt32
    with_target(get_feature_count)
  end

  # Finds the feature ID of a feature, given its index in the device's internal feature table.
  def feature_id(feature_index : UInt8) : UInt16
    with_target(get_feature_id, feature_index)
  end

  # Given a feature's ID, returns its index in the device's internal table.
  def feature_index(feature_id : UInt16) : UInt8
    with_target(get_feature_index, feature_id)
  end

  # Flushes pending inbound events, processing G-key presses if present.
  def flush
    raise Error.from_lib unless LibKeyleds.flush_fd(@device)
  end

  # Remove the given keys, represented by their scancodes, from the game mode block list.
  def gamemode_remove(scancodes : Array(UInt8))
    try(gamemode_clear, scancodes.to_unsafe, scancodes.size)
  end

  # Returns the maximum possible number of keys that can be blocked at a time during game mode.
  def gamemode_max_blocked : UInt32
    try(gamemode_max, out max)
    max
  end

  # Resets the game mode blocked key list to empty.
  def gamemode_reset
    try(gamemode_reset)
  end

  # Adds the given keys, represented by their scancodes, to the game mode block list.
  def gamemode_add(scancodes : Array(UInt8))
    try(gamemode_set, scancodes.to_unsafe, scancodes.size)
  end

  # Returns the number of G-keys available on the device.
  def gkeys_count : UInt32
    try(gkeys_count, out count)
    count
  end

  # Returns the device's declared international keyboard layout.
  def keyboard_layout : KeyboardLayout
    with_target(keyboard_layout)
  end

  # Starting at `key_offset` within the given block, returns `num_keys` current LED states.
  def leds(block : BlockId, key_offset : UInt16, num_keys : UInt32) : Array(KeyColor)
    Array(KeyColor).build(num_keys) do |buf|
      try(get_leds, block, buf, offset, num_keys)
      num_keys
    end
  end

  # Returns the name of the device.
  def name : String
    try(get_device_name, out ptr)
    String.new(ptr)
  end

  # Defines a callback that should be run whenever a G-key (or M/MR-key) is pressed.
  # The second parameter is a `BitArray`, with the first bit representing the first key in the group.
  # Triggered by `Device#flush`.
  #
  # ```
  # Keyleds::Device.open("/dev/hidraw1", 1) do |dev|
  #   dev.custom_gkeys(true)
  #
  #   dev.on_gkey do |type, keys|
  #     puts "is the first key on? #{keys[0]}"
  #   end
  #
  #   loop { dev.flush } # is the first key on? false
  # end
  # ```
  def on_gkey(&callback : GkeysType, BitArray ->)
    count = gkeys_count.to_i
    # wrapper callback to avoid closure problems
    mask_callback = ->(type : GkeysType, mask : UInt16) {
      # Pretty sure there are always the same amount of M/MR keys present on any keyboard that has them
      size = case type
        in .gkey?  then count
        in .mkey?  then 3
        in .mrkey? then 1
      end
      arr = BitArray.new(size)
      0.upto(size - 1) do |i|
        arr[i] = mask.bit(i) == 1
      end
      callback.call(type, arr)
    }

    box = Box.box(mask_callback)
    @cb = box

    with_target(gkeys_set_cb, ->(device, target, type, mask, data) {
      Box(typeof(mask_callback)).unbox(data).call(type, mask)
    }, box)
  end

  # Resynchronizes with the device.
  # Use as a recovery mechanism after another call has errored.
  def ping
    try(ping)
  end

  # Returns the device's current protocol.
  def protocol : ProtocolSpec
    try(get_protocol, out version, out handler)
    {version: version, handler: handler}
  end

  # Returns the device's current report rate.
  def reportrate : UInt32
    try(get_reportrate, out rate)
    rate
  end

  # Sets the LED color for the given keys.
  # Must be committed with `Device#commit_leds`.
  def set_leds(block : BlockId, keys : Array(KeyColor))
    try(block, keys.to_unsafe, keys.size)
  end

  # Sets the entire LED block to a single uniform color.
  # Must be committed with `Device#commit_leds`.
  def set_led_block(block : BlockId, red : UInt8, green : UInt8, blue : UInt8)
    try(set_led_block, block, red, green, blue)
  end

  # Sets the lighting state for the M keys.
  def set_mkeys(state : {Bool, Bool, Bool})
    mask = state.each_with_index.reduce(0_u8) { |acc, (e, i)| acc | ((e ? 1 : 0) << i) }
    puts mask
    try(mkeys_set, mask)
  end

  # Sets the lighting state for the MR key.
  def set_mrkey(state : Bool)
    try(mrkeys_set, state ? 1 : 0)
  end

  # Sets the keyboard's report rate to `rate`.
  def set_reportrate(rate : UInt32)
    try(set_reportrate, rate)
  end

  # Sets the device's HID++ command timeout.
  def set_timeout(microseconds : UInt32)
    LibKeyleds.set_timeout(@device, microseconds)
  end

  # Gets all supported report rates.
  def supported_rates : Array(UInt32)
    try(get_reportrates, out rates)
    arr = [] of UInt32
    (0..).each do |i|
      rate = rates[i]
      break unless rate == 0
      arr << rate
    end
    arr
  end

  # Returns the device's type.
  # See `Type` for more info.
  def type : Type
    try(get_device_type, out type)
    type
  end

  # Returns the device's current firmware version.
  def version : Version
    try(get_device_version, out version_ptr)
    v = version_ptr.value

    # ditto
    data_ptr = (version_ptr.as(UInt8*) + offsetof(LibKeyleds::DeviceVersion, @protocols)).as(LibKeyleds::DeviceProtocol*)
    protocols = Slice.new(data_ptr, v.length).map do |p|
      Protocol.new(
        p.type,
        String.new(p.prefix.to_unsafe),
        p.version_major,
        p.version_minor,
        p.build,
        p.is_active,
        p.product_id,
        p.misc
      )
    end.to_a

    Version.new(v.serial, v.transport, v.model, protocols)
  end

  # NOTE: After going through the other keyleds sources, only TARGET_DEFAULT is ever used for the target parameter.
  # What's its actual purpose? Dunno, but everything breaks if you use anything else.

  private macro try(method, *params)
    unless with_target({{method}}, {{*params}})
      raise Error.from_lib
    end
  end

  private macro with_target(method, *params)
    LibKeyleds.{{method}}(@device, LibKeyleds::TARGET_DEFAULT, {{*params}})
  end
end
