require "./libkeyleds"

struct LibKeyleds::KeyblocksInfo
  def to_slice
    Slice.new(pointerof(@blocks), @length)
  end
end

module Keyleds
  alias BlockId = LibKeyleds::BlockId
  alias GkeysType = LibKeyleds::GkeysType
  alias Keyblock = LibKeyleds::Keyblock
  alias KeyboardLayout = LibKeyleds::KeyboardLayout
  alias KeyColor = LibKeyleds::KeyColor

  class Device
    alias Handler = LibKeyleds::DeviceHandler
    alias Type = LibKeyleds::DeviceType

    alias ProtocolSpec = {version: UInt32, handler: Handler}

    record Protocol,
      type : UInt8,
      prefix : String,
      version_major : UInt32,
      version_minor : UInt32,
      build : UInt32,
      is_active : Bool,
      product_id : UInt16,
      misc : UInt8[5]

    record Version,
      serial : UInt8[4],
      transport : UInt16,
      model : UInt8[6],
      protocols : Array(Protocol)
  end
end
