require "./libkeyleds"

module Keyleds::Codes
  def self.to_keycode(block : LibKeyleds::BlockId, scancode : UInt8)
    LibKeyleds.translate_scancode(block, scancode)
  end

  def self.to_scancode(keycode : UInt32)
    if LibKeyleds.translate_keycode(keycode, out block, out scancode)
      {block: block, scancode: scancode}
    else
      raise ArgumentError.new("keycode #{keycode} does not correspond to a Logitech key identifier")
    end
  end
end
