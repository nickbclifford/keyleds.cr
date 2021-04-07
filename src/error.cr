require "./libkeyleds"

class Keyleds::Error < Exception
  def self.from_lib
    new String.new(LibKeyleds.get_error_str)
  end
end
