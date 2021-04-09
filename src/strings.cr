require "./libkeyleds"

# Module containing mapping hashes between various integer IDs and their human-readable names.
module Keyleds::Strings
  {% for name in %w(block_id_names device_types feature_names keycode_names protocol_types) %}
    {{name.upcase.id}} = begin
      hash = {} of UInt32 => String
      (0..).each do |i|
        entry = LibKeyleds.keyleds_{{name.id}}.to_unsafe[i]
        break if entry.id == 0 && entry.str.null?
        hash[entry.id] = String.new(entry.str)
      end
      hash
    end
  {% end %}
end
