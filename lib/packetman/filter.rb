module Packetman
  class Filter
    include ConfigMethods

    attr_accessor :input

    def initialize(input)
      self.input = input
      yield config if block_given?
    end

    def self.bit_length(num)
      case num
      when /^0x/
        $'.length * bit_density(16)
      when /^0b/
        $'.length * bit_density(2)
      else
        nil
      end
    end

    def self.bit_density(radix=config.radix)
      (radix.nil?) ? 8 : Math.log2(radix).to_i
    end

    def map_chr
      pad_right(input.scan(/./).map{ |chr| yield chr }.join)
    end

    def pad_right(bin_str)
      bin_str.ljust(desired_length, '0')
    end

    def desired_length
      ((input.length + config.offset_bits)/8.to_f).ceil*8 - config.offset_bits
    end

    def radix_mask
      ("1"*self.class.bit_density).to_i(2)
    end

    def mask_chr(chr)
      if chr == config.wildcard
        0
      else
        radix_mask
      end.to_s(2).rjust(self.class.bit_density, '0')
    end

    def bin_chr(chr)
      chr = '0' if chr == config.wildcard

      if config.radix
        raise "invalid character '#{chr}' for radix=#{config.radix}" if chr.downcase != chr.to_i(config.radix).to_s(config.radix).downcase
        chr.to_i(config.radix)
      else
        chr.ord
      end.to_s(2).rjust(self.class.bit_density, '0')
    end

    def mask_hex
      hex_encode(map_chr{ |c| mask_chr(c) })
    end

    def search_hex
      hex_encode(map_chr{ |c| bin_chr(c) })
    end

    def hex_encode(bin_str)
      bin_str.reverse.scan(/.{1,4}/).map{ |chunk|
        chunk.reverse.to_i(2).to_s(16)
      }.reverse.join.scan(/.{8}|.{4}|.{2}/).map{ |hex|
        hex.prepend('0x')
      }
    end

    def to_s
      offset = 0
      [].tap do |filter|
        search_hex.zip(mask_hex).each do |search, mask|
          filter << Packetman::Clause.new(search, mask, offset)
          offset += self.class.bit_length(search)
        end
      end.map{ |b| b.to_s }.join(' && ')
    end

  end
end
