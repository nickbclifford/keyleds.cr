require "./bridge"
require "./libkeyleds"

# Module containing utility functions for converting between Logitech internal scancodes
# and standard [Linux kernel keycodes](https://github.com/torvalds/linux/blob/master/include/uapi/linux/input-event-codes.h).
module Keyleds::Codes
  alias LogitechScancode = {block: BlockId, scancode: UInt8}

  # Given a key scancode and the key block it resides in, returns the corresponding Linux keycode.
  def self.to_keycode(block : BlockId, scancode : UInt8) : UInt32
    LibKeyleds.translate_scancode(block, scancode)
  end

  # Given a Linux input keycode, returns the Logitech key scancode and the key block it resides in.
  def self.to_scancode(keycode : UInt32) : LogitechScancode
    if LibKeyleds.translate_keycode(keycode, out block, out scancode)
      {block: block, scancode: scancode}
    else
      raise ArgumentError.new("keycode #{keycode} does not correspond to a Logitech scancode")
    end
  end
end
