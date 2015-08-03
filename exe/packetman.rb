#!/usr/bin/env ruby

require 'optparse'

$options = {}
opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: #{__FILE__} [OPTIONS] FILTER_STRING"
  opt.on("-t", "--transport [PROTO]", String, "Transport Protocol (tcp|udp)") {|v| $options[:transport] = v }
  opt.on("-a", "--application [PROTO]", String, "Application Protocol (http|dns|icmp)") {|v| $options[:application] = v }
  opt.on("-o", "--transport-offset [OFFSET]", Integer, "Offset from beginning of transport header") {|v| $options[:offset] = v; $options[:offset_type] = :transport }
  opt.on("-O", "--application-offset [OFFSET]", Integer, "Offset from beginning of application header") {|v| $options[:offset] = v; $options[:offset_type] = :application }
  opt.on("-e", "--expression", "Treat FILTER_STRING as an expression") { $options[:expression] = true }
end
opt_parser.parse!

#defaults
$options[:transport] ||= "tcp"
$options[:application] ||= "http"
$options[:offset] ||= 0
$options[:offset_units] ||= :octets
$options[:offset_type] ||= :application
#
#invalid options
if $options[:transport] !~ /tcp|udp/i ||
  $options[:application] !~ /http|dns|icmp/i
  puts opt_parser
  exit 1
end

#normalize
if $options[:offset_units] == :bits
  $options[:offset] /= 8.to_f
  $options[:offset_units] = :octets
end
