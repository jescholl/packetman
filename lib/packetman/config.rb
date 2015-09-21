require 'optparse'

module Packetman
  class Config
    attr_accessor :transport, :application, :use_bytes, :allow_wildcards, :radix, :start_with_transport
    attr_writer :offset

    def initialize
      @transport = "tcp"
      @offset = 0
    end

    def protocols
      @protocols ||= YAML.load(File.read(File.expand_path('../../../config/protocols.yml', __FILE__)))
    end

    def payload_query
      if start_with_transport
        "0"
      else
        protocols[transport]['payload_query']
      end
    end

    def offset
      if use_bytes
        @offset*8
      else
        @offset
      end
    end

    def parse_opts
      @opts ||= OptionParser.new do |opt|
        opt.banner = "Usage: #{File.basename($PROGRAM_NAME)} [OPTIONS] FILTER_STRING"
        opt.on("-p", "--protocol [PROTO]", protocols.keys, "Transport Protocol (#{protocols.keys.join(',')})") {|v| self.transport = v }
        opt.on("-t", "--transport", "OFFSET starts at transport header instead of data field") { |v| self.start_with_transport = v }
        opt.on("-r", "--radix [RADIX]", Integer, "Treat FILTER_STRING as RADIX instead of String") {|v| self.radix = v; }
        opt.on("-o", "--offset [OFFSET]", Integer, "Offset in bits") {|v| self.offset = v; }
        opt.on("-b", "--byte-offset", "Use 8-bit bytes instead of bits for offset") { |v| self.use_bytes = v }
        opt.on("-w", "--wildcards", "Allow '?' wildcards") { |v| self.allow_wildcards = v }
        opt.on("--version", "Show version") { puts Packetman::Version }
      end

      @opts.parse!

      raise "Invalid command line arguments" if ARGV.size != 1

      ARGV.pop
    end

  end
end
