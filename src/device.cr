require "./error"
require "./libkeyleds"

id_range = LibKeyleds::APP_ID_MIN..LibKeyleds::APP_ID_MAX

class Keyleds::Device
  @device : LibKeyleds::Keyleds

  def initialize(path : String, app_id : UInt8)
    unless id_range.includes?(app_id)
      raise ArgumentError.new("app id must be between #{id_range.start} and #{id_range.end}")
    end

    # error state indicated by null pointer
    unless @device = LibKeyleds.open(path, app_id)
      raise Error.from_keyleds
    end
  end

  def close
    LibKeyleds.close(@device)
  end

  # NOTE: After going through the other keyleds sources, only TARGET_DEFAULT is ever used for this parameter.
  # What's its actual purpose? Dunno, but everything breaks if you use anything else.

  def name
    try(get_device_name, @device, LibKeyleds::TARGET_DEFAULT, out ptr)
    String.new(ptr)
  end

  def flush
    try(flush_fd, @device)
  end

  def custom_gkeys(enabled)
    try(gkeys_enable, @device, LibKeyleds::TARGET_DEFAULT, enabled)
  end

  def gkeys_count
    try(gkeys_count, @device, LibKeyleds::TARGET_DEFAULT, out count)
    count
  end

  @cb : Pointer(Void)?

  def on_gkey(&callback : LibKeyleds::GkeysTypeT, UInt16 ->)
    box = Box.box(callback)
    @cb = box

    LibKeyleds.gkeys_set_cb(@device, LibKeyleds::TARGET_DEFAULT, ->(device, target, type, mask, data) {
      Box(typeof(callback)).unbox(data).call(type, mask)
    }, box)
  end

  private macro try(method, *params)
    unless LibKeyleds.{{method}}({{*params}})
      raise Error.from_lib
    end
  end
end
