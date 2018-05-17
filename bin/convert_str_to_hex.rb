#!/usr/bin/env ruby

def convert_str_to_hex(str)
  str.each_char.map do |c|
    sprintf '0x%02x', c.unpack('H*').first.to_i
  end
end

result = convert_str_to_hex(ARGV[0])
puts result.join(', ')
