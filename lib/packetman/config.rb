require 'optparse'

module Packetman
  class Config
    attr_accessor :transport, :application, :use_bytes, :radix, :start_with_transport, :offset, :wildcard

    def initialize
      @transport = "tcp"
      @offset = 0
    end

    def protocols
      @protocols ||= YAML.load(File.read(File.expand_path('../../../config/protocols.yml', __FILE__)))
    end

    def payload_query
      protocols[transport]['payload_query'] unless start_with_transport
    end

    def offset_bits
      if use_bytes
        offset*8
      else
        offset
      end
    end

    def opts
      @opts ||= OptionParser.new do |opt|
        opt.banner = "Usage: #{File.basename($PROGRAM_NAME)} [OPTIONS] FILTER_STRING"
        opt.on("-p", "--protocol PROTO", protocols.keys, "Transport Protocol ( #{protocols.keys.join(',')})") { |v| self.transport = v }
        opt.on("-t", "--transport", "OFFSET starts at transport header instead of data payload") { |v| self.start_with_transport = v }
        opt.on("-r", "--radix RADIX", Integer, "Treat FILTER_STRING as RADIX instead of String") { |v| self.radix = v }
        opt.on("-o", "--offset OFFSET", Integer, "Offset in bits") { |v| self.offset = v }
        opt.on("-b", "--byte-offset", "Use 8-bit bytes instead of bits for offset") { |v| self.use_bytes = v }
        opt.on("-w", "--wildcard [CHARACTER=?]", "Treat CHARACTER as single-character wildcard") { |v| raise "invalid wildcard" if v.to_s.length > 1; self.wildcard = v || '?' }
        opt.on("-v", "--version", "Show version") { puts Packetman::VERSION; exit }
      end
    end


    def parse_opts
      filter_str = ARGV.pop
      raise "Invalid command line arguments" unless filter_str
      opts.parse!
      filter_str
    end

  end
end
