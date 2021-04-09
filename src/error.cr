require "./libkeyleds"

# An `Error` is raised whenever `Keyleds` encounters an internal problem, such as when interfacing with a device.
class Keyleds::Error < Exception
  # :nodoc:
  def self.from_lib
    if LibKeyleds.get_errno == :errno
      new Errno.value.message
    else
      new String.new(LibKeyleds.get_error_str)
    end
  end
end
