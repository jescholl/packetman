module Packetman
  class Config
    attr_accessor :transport, :application, :offset, :offset_units, :offset_type, :table_cols, :table_delim

    def initialize(opt_hash = {})

      @transport = opt_hash[:transport] || :tcp
      @application = opt_hash[:application] || :http
      @offset = opt_hash[:offset] || 0
      @offset_units = opt_hash[:offset_units] || :octets
      @offset_type = opt_hash[:offset_type] || :application
      @table_cols = opt_hash[:table_cols] || 32
      @table_delim = opt_hash[:table_delim] || '|'
    end

    def self.[](protocol)
      @@protocols[protocol]
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

    def protocols
      @@protocols ||= {
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
  end
end
