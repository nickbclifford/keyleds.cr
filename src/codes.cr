require "./bridge"
require "./libkeyleds"

module Keyleds::Codes
  alias LogitechScancode = {block: BlockId, scancode: UInt8}

  def self.to_keycode(block : BlockId, scancode : UInt8) : UInt32
    LibKeyleds.translate_scancode(block, scancode)
  end

  def self.to_scancode(keycode : UInt32) : LogitechScancode
    if LibKeyleds.translate_keycode(keycode, out block, out scancode)
      {block: block, scancode: scancode}
    else
      raise ArgumentError.new("keycode #{keycode} does not correspond to a Logitech key identifier")
    end
  end
end
