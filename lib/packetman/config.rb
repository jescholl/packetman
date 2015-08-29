require 'optparse'

module Packetman
  class Config
    attr_accessor :transport, :application, :offset, :offset_units, :offset_type, :table_cols, :table_delim, :allow_wildcards

    def initialize(opt_hash = {})
      @transport = :tcp
      @application = :http
      @offset = 0
      @offset_units = :octets
      @offset_type = :application
      @table_cols = 32
      @table_delim = '|'
      @allow_wildcards = true
    end

    def parse
      OptionParser.new do |opt|
        opt.banner = "Usage: #{__FILE__} [OPTIONS] FILTER_STRING"
        opt.on("-t", "--transport [PROTO]", String, "Transport Protocol (tcp|udp)") {|v| self.transport = v }
        opt.on("-a", "--application [PROTO]", String, "Application Protocol (http|dns|icmp)") {|v| self.application = v }
        opt.on("-o", "--transport-offset [OFFSET]", Integer, "Offset from beginning of transport header") {|v| self.offset = v; self.offset_type = :transport }
        opt.on("-O", "--application-offset [OFFSET]", Integer, "Offset from beginning of application header") {|v| self.offset = v; self.offset_type = :application }
        opt.on("-e", "--expression", "Treat FILTER_STRING as an expression") { self.expression = true }
        opt.on("--[no]wildcards", "") { |v| self.allow_wildcards = v }
      end.parse!

      if transport !~ /tcp|udp/i ||
        application !~ /http|dns|icmp/i
        raise "invalid options"
      end

      if offset_units == :bits
        offset /= 8.to_f
        offset_units = :octets
      end
    end

#    def protocols
#      @@protocols ||= {
#        :tcp => {
#          :labels => ['Source Port', 'Destination Port', 'Sequence Number', 'Acknowledgement Number', 'Data Offset', 'RESERVED', 'ECN', 'Control Bits', 'Window', 'Checksum', 'Urgent Pointer', 'Options and Padding'],
#          :sizes => [16,16,32,32,4,3,3,6,16,16,16,32],
#          :query => "((tcp[12:1] & 0xf0) >> 2)",
#        },
#        :udp => {
#          :labels => ['Source Port', 'Destination Port', 'Length', 'Checksum'],
#          :sizes => [16,16,16,16],
#          :query => "8"
#        }
#      }
#    end
    def protocol_defaults
      {
        :tcp => {
          :table => {'Source Port' => 16, 'Destination Port' => 16, 'Sequence Number' => 32, 'Acknowledgement Number' => 32, 'Data Offset' => 4, 'RESERVED' => 3, 'ECN' => 3, 'Control Bits' => 6, 'Window' => 16, 'Checksum' => 16, 'Urgent Pointer' => 16, 'Options and Padding' => 32},
          :query => "((tcp[12:1] & 0xf0) >> 2)",
        },
        :udp => {
          :table => {'Source Port' => 16, 'Destination Port' => 16, 'Length' => 16, 'Checksum' => 16},
          :query => "8"
        }
      }
    end

    def protocols
      @protocols ||= protocol_defaults
    end
  end
end
