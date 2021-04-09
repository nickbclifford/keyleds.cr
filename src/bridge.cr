require "./libkeyleds"

module Keyleds
  # Enum describing a keyboard's different key blocks.
  alias BlockId = LibKeyleds::BlockId

  # Enum describing the possible kinds of keys that trigger a G-key callback.
  alias GkeysType = LibKeyleds::GkeysType

  # Structure representing the number of keys in a key block and its current color.
  alias Keyblock = LibKeyleds::Keyblock

  # Enum describing a device's declared keyboard layout.
  # **This is not an exhaustive list**, contributions to expand it are welcome.
  alias KeyboardLayout = LibKeyleds::KeyboardLayout

  # Structure representing the position and color of a key.
  alias KeyColor = LibKeyleds::KeyColor

  class Device
    # Enum describing the recommended use of a device.
    alias Handler = LibKeyleds::DeviceHandler

    # Enum describing the possible kinds of Logitech devices.
    alias Type = LibKeyleds::DeviceType

    alias ProtocolSpec = {version: UInt32, handler: Handler}

    # Describes a protocol that a device can communicate over.
    record Protocol,
      type : UInt8,
      prefix : String,
      version_major : UInt32,
      version_minor : UInt32,
      build : UInt32,
      is_active : Bool,
      product_id : UInt16,
      misc : UInt8[5]

    # Describes the current firmware version of a device.
    record Version,
      serial : UInt8[4],
      transport : UInt16,
      model : UInt8[6],
      protocols : Array(Protocol)
  end
end
