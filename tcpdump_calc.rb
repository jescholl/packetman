#!/usr/bin/env ruby

####################################################
# tcpdump output parser for monitoring dns queries #
####################################################
#
# This is intended to be run as 
#   sudo tcpdump -vvv -s 0 -l -n port 53 | ./parse_tcpdump_dns.rb
#
# This is basically just a ruby port of Jon Tai's php script 
#   https://gist.github.com/jtai/1368338
#
# For more information, see his blog post where he explains it all
#   http://jontai.me/blog/2011/11/monitoring-dns-queries-with-tcpdump/
#
require 'optparse'

#$t_proto = {
#    'tcp' => {
#    :labels => ['Source Port', 'Destination Port', 'Sequence Number', 'Acknowledgement Number', 'Data Offset', 'RESERVED', 'ECN', 'Control Bits', 'Window', 'Checksum', 'Urgent Pointer', 'Options and Padding'],
#    :sizes => [16,16,32,32,4,3,3,6,16,16,16,32],
#    :query => "((tcp[12:1] & 0xf0) >> 2)",
#  },
#  'udp' => {
#    :labels => ['Source Port', 'Destination Port', 'Length', 'Checksum'],
#    :sizes => [16,16,16,16],
#    :query => "8"
#  }
#}

#def header_table(labels, sizes)
#  if labels.length == sizes.length
#
#    output = horiz_only =  sprintf "|%s|\n", "-"*(64+31)
#    output += sprintf "|%02d"*32 + "|\n", *[*0..31]
#    output += horiz_only
#    tmp_output = "|"
#
#    labels.zip(sizes).each do |label, size|
#      cell_size = size*3 - 1
#      tmp_output += sprintf "%.#{cell_size}s|", label.center(cell_size)
#
#      if tmp_output.length == 32*3 + 1
#        output += tmp_output + "\n"
#        output += horiz_only
#        tmp_output = "|"
#      end
#    end
#    output
#  end
#end
#
#def user_input(prompt)
#  puts prompt
#  gets
#end

#$options = {}
#opt_parser = OptionParser.new do |opt|
#  opt.banner = "Usage: #{__FILE__} [OPTIONS] FILTER_STRING"
#  opt.on("-t", "--transport [PROTO]", String, "Transport Protocol (tcp|udp)") {|v| $options[:transport] = v }
#  opt.on("-a", "--application [PROTO]", String, "Application Protocol (http|dns|icmp)") {|v| $options[:application] = v }
#  opt.on("-o", "--transport-offset [OFFSET]", Integer, "Offset from beginning of transport header") {|v| $options[:offset] = v; $options[:offset_type] = :transport }
#  opt.on("-O", "--application-offset [OFFSET]", Integer, "Offset from beginning of application header") {|v| $options[:offset] = v; $options[:offset_type] = :application }
#  opt.on("-e", "--expression", "Treat FILTER_STRING as an expression") { $options[:expression] = true }
#end
#opt_parser.parse!
#
#
##(udp[11] & 0x03 = 0x03)
#
#
##defaults
#$options[:transport] ||= "tcp"
#$options[:application] ||= "http"
#$options[:offset] ||= 0
#$options[:offset_units] ||= :octets
#$options[:offset_type] ||= :application
#
##invalid options
#if $options[:transport] !~ /tcp|udp/i ||
#  $options[:application] !~ /http|dns|icmp/i 
#  puts opt_parser
#  exit 1
#end
#
##normalize
#if $options[:offset_units] == :bits
#  $options[:offset] /= 8.to_f
#  $options[:offset_units] = :octets
#end

puts $options[:offset]
puts $options[:transport]
puts $options[:application]

#def hex_encode(input)
#  if input.kind_of?(Integer)
#    input.to_s(16).scan(/.{1,8}/).map{ |s| s.insert(0, '0x') }
#  elsif input.kind_of?(String)
#    input.scan(/./).map{ |c| c.ord.to_s(16) }.join.scan(/.{1,8}/).map{ |s| s.insert(0, '0x') }
#  end
#end
#
#def compose_string(input, offset)
#  extrabits = offset % 8
#  offset    = offset / 8
#
#  if input =~ /^0b([01\?]+)$/i
#    match = $1
#    #p match
#    #p match.gsub('?', '0')
#    #p hex_encode(match.gsub('?', '0').to_i(2))
#    search = hex_encode(match.gsub('?', '0').to_i(2))
#    #p search
#    octets = ((match.length + extrabits) / 8.to_f).ceil
#    mask = hex_encode(match.gsub('0', '1').gsub('?', '0').to_i(2))
#    #bitwise_offset = input.index(/[^0x\?]/i)
#  elsif input =~ /^0x([0-9a-f\?]+)$/i
#    match = $1
#    search = hex_encode(match.gsub('?', '0').to_i(16))
#    octets = ((match.length*4 + extrabits) / 8.to_f).ceil
#    mask = hex_encode(match.gsub(/[^\?]/, 'f').gsub('?', '0').to_i(16))
#    #bitwise_offset = input.index(/[^0b\?]/i)
#  else
#    match = input
#    search = hex_encode(match)
#    octets = ((match.length*8 + extrabits) / 8.to_f).ceil
#    mask = []
#    mask.fill(nil, 0, search.length)
#  end
#
#  p [search, mask]
#  output = []
#  search.zip(mask).each_with_index do |(search,mask),i|
#    output << "(#{$options[:transport]}[#{offset + i*4}:#{octets}]#{mask ? " & #{mask}" : '' }) = #{search}"
#  end
#
#  output.join(' && ')
#
#end
#FIXME add something to select header fields rather than needing to count, or a header map


if $options[:offset_type] == :transport
#  puts header_table($t_proto[$options[:transport]][:labels], $t_proto[$options[:transport]][:sizes])
  loop do
    offset = user_input("Starting Bit (multiple of 8): ")
  end while offset % 8 != 0

  compose_string(user_input("search string (wildcard: ?)", offset))



elsif $options[:offset_type] == :application

else
  warn "error, invalid offset_type: #{$options[:offset_type]}"
  exit 2
end


def test
  puts header_table($t_proto[$options[:transport]][:labels], $t_proto[$options[:transport]][:sizes])
  p compose_string("0b??101?", 106)
  p compose_string("0x??101?", 106)
  p compose_string("this is a test", 106)

end
test

def test2(mask, search)
  [0b11111011,
   0b11111010,

   0b11101011,
   0b11101010,

   0b11011011,
   0b11011010,

   0b11001011,
   0b11001010].each do |raw|
    puts "\n"
      printf "    %010d &\n    %010d\n    ============\n    %010d\n", raw.to_s(2), mask.to_s(2), search.to_s(2)
    if raw & mask == search
      puts "worked\n"
    else
      puts "    FAILED\n"
    end
  end
end
