require 'optparse'

module Packetman
  class Config
    attr_accessor :transport, :application, :offset_type, :radix, :start_with_transport, :offset, :wildcard

    def initialize
      self.transport = "tcp"
      self.offset = 0
      self.offset_type = :bits
    end

    def protocols
      @protocols ||= YAML.load(File.read(File.expand_path('../../../config/protocols.yml', __FILE__)))
    end

    def payload_query
      protocols[transport]['payload_query'] unless start_with_transport
    end

    def offset_bits
      if offset_type == :bytes
        offset*8
      else
        offset
      end
    end

    def opts
      @opts ||= OptionParser.new do |opt|
        opt.banner = "Usage: #{File.basename($PROGRAM_NAME)} [OPTIONS] FILTER_STRING"
        opt.on("-p", "--protocol PROTO", protocols.keys, "Transport Protocol (#{protocols.keys.join(',')})") { |v| self.transport = v }
        opt.on("-t", "--transport", "OFFSET starts at transport header instead of data payload") { |v| self.start_with_transport = v }
        opt.on("-r", "--radix RADIX", Integer, "Treat FILTER_STRING as RADIX instead of String") { |v| self.radix = v }
        opt.on("-o", "--offset OFFSET", Integer, "Offset in bits") { |v| self.offset = v }
        opt.on("-b", "--byte-offset", "Use 8-bit bytes instead of bits for offset") { |v| self.offset_type = :bytes if v }
        opt.on("-w", "--wildcard CHARACTER", "Treat CHARACTER as single-character wildcard") { |v| raise "invalid wildcard" if v.to_s.length > 1; self.wildcard = v }
        opt.on("--table", "Show transport header table") { puts Packetman::Table.new; throw :exit }
        opt.on("-v", "--version", "Show version") { puts Packetman::VERSION; throw :exit }
      end
    end

    def parse_opts
      unparsed_opts = opts.parse!
      if unparsed_opts.length < 1
        puts opts
        throw :exit
      end
      unparsed_opts.join(" ")
    end

  end
end
