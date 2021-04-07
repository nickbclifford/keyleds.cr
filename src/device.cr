require "./error"
require "./libkeyleds"

class Keyleds::Device
  APP_IDS = LibKeyleds::APP_ID_MIN..LibKeyleds::APP_ID_MAX

  # For GC purposes
  @cb : Pointer(Void)?

  @device : LibKeyleds::Keyleds

  def initialize(path : String, app_id : UInt8)
    unless APP_IDS.includes?(app_id)
      raise ArgumentError.new("app id must be between #{APP_IDS.begin} and #{APP_IDS.end}")
    end

    # error state indicated by null pointer
    unless @device = LibKeyleds.open(path, app_id)
      raise Error.from_lib
    end
  end

  def close
    LibKeyleds.close(@device)
  end

  def block_info
    try(get_block_info, out ptr)
    info = ptr.value
    Slice.new(info.blocks.to_unsafe, info.length)
  end

  def commit_leds
    try(commit_leds)
  end

  def custom_gkeys(enabled : Bool)
    try(gkeys_enable, enabled)
  end

  def fd
    IO::FileDescriptor.new(LibKeyleds.device_fd(@device))
  end

  def feature_count
    with_target(get_feature_count)
  end

  def feature_id(feature_index : UInt8)
    with_target(get_feature_id, feature_index)
  end

  def feature_index(feature_id : UInt16)
    with_target(get_feature_index, feature_id)
  end

  def flush
    raise Error.from_lib unless LibKeyleds.flush_fd(@device)
  end

  def gamemode_remove(key_ids : Array(UInt8))
    try(gamemode_clear, key_ids.to_unsafe, key_ids.size)
  end

  def gamemode_max_blocked
    try(gamemode_max, out max)
    max
  end

  def gamemode_reset
    try(gamemode_reset)
  end

  def gamemode_add(key_ids : Array(UInt8))
    try(gamemode_set, key_ids.to_unsafe, key_ids.size)
  end

  def gkeys_count
    try(gkeys_count, out count)
    count
  end

  def keyboard_layout
    LibKeyleds
  end

  def leds(block : LibKeyleds::BlockId, offset : UInt16, num_keys : UInt32)
    Array(LibKeyleds::KeyColor).build(num_keys) do |buf|
      try(get_leds, block, buf, offset, num_keys)
      num_keys
    end
  end

  def name
    try(get_device_name, out ptr)
    String.new(ptr)
  end

  def on_gkey(&callback : LibKeyleds::GkeysType, UInt16 ->)
    box = Box.box(callback)
    @cb = box

    with_target(gkeys_set_cb, ->(device, target, type, mask, data) {
      Box(typeof(callback)).unbox(data).call(type, mask)
    }, box)
  end

  def ping
    try(ping)
  end

  def protocol
    try(get_protocol, out version, out handler)
    {version: version, handler: handler}
  end

  def reportrate
    try(get_reportrate, out rate)
    rate
  end

  def set_leds(block : BlockId, keys : Array(KeyColor))
    try(block, keys.to_unsafe, keys.size)
  end

  def set_led_block(block : BlockId, red : UInt8, green : UInt8, blue : UInt8)
    try(set_led_block, block, red, green, blue)
  end

  def set_mkeys(mask : UInt8)
    try(mkeys_set, mask)
  end

  def set_mrkeys(mask : UInt8)
    try(mrkeys_set, mask)
  end

  def set_reportrate(rate : UInt32)
    try(set_reportrate, rate)
  end

  def set_timeout(microseconds : UInt32)
    LibKeyleds.set_timeout(@device, microseconds)
  end

  def supported_rates
    try(get_reportrates, out rates)
    arr = [] of UInt32
    (0..).each do |i|
      rate = rates[i]
      break unless rate == 0
      arr << rate
    end
    arr
  end

  def type
    try(get_device_type, out type)
    type
  end

  def version
    try(get_device_version, out version_ptr)
    version_ptr.value
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
