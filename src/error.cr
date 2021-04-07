require "./libkeyleds"

class Keyleds::Error < Exception
  def self.from_lib
    if LibKeyleds.get_errno == :errno
      new String.new(Errno.value.message)
    else
      new String.new(LibKeyleds.get_error_str)
    end
  end
end
