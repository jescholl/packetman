require 'optparse'

module Packetman
  class Config
    attr_accessor :transport, :application, :offset_units, :offset_type, :allow_wildcards
    attr_writer :offset

    def initialize
      @transport = "tcp"
      @application = "http"
      @offset = 0
      @offset_units = "bits"
      @offset_type = "application"
      @allow_wildcards = true
    end

    def protocols
      @protocols ||= YAML.load(File.read(File.expand_path('../../../config/protocols.yml', __FILE__)))
    end

    def payload_query
      case offset_type
      when "application"
        protocols[transport.to_s]['payload_query']
      else
        "0"
      end
    end

    def offset
      case offset_units
      when "bytes"
        @offset*8
      else
        @offset
      end
    end

    def parse_opts
      @opts ||= OptionParser.new do |opt|
        opt.banner = "Usage: #{__FILE__} [OPTIONS] FILTER_STRING"
        opt.on("-t", "--transport [PROTO]", protocols.keys, "Transport Protocol (#{protocols.keys.join(',')})") {|v| self.transport = v }
        opt.on("-a", "--application [PROTO]", ['http', 'dns', 'icmp'], "Application protocol (http, dns, icmp)") { |v| self.application = v }
        #opt.on("-a", "--application [PROTO]", String, "Application Protocol (http|dns|icmp)") {|v| self.application = v }
        opt.on("-o", "--offset [OFFSET]", Integer, "Offset in bits") {|v| self.offset = v; }
        opt.on("-b", "--byte-offset", "Use 8-bit bytes instead of bits for offset") { |v| self.offset_units = "bytes" }
        opt.on("-O", "--offset-type [TYPE]", ["application", "transport"], "Begin offset at the application/transport header.") { |v|  self.offset_type = v }
        opt.on("--[no]wildcards", "Allow '?' wildcards") { |v| self.allow_wildcards = v }
      end

      @opts.parse!


#      if transport !~ /tcp|udp/i ||
#        application !~ /http|dns|icmp/i
#        raise "invalid options"
#      end
#
#      if offset_units == :bits
#        offset /= 8.to_f
#        offset_units = :octets
#      end
    end

  end
end
