module Packetman
  class Compose

    def initialize(input, radix=nil)
      @input = input
      @radix = radix
    end
    
    def desired_length
      ((@input.length + Packetman.config.offset)/8.to_f).ceil*8 - Packetman.config.offset
    end

    def bit_density(radix=@radix)
      (radix.nil?) ? 8 : Math.log2(radix).to_i
    end

    def mask
      shift(@input.scan(/./).map{ |c| mask_chr(c) }.join)
    end

    def radix_mask
      ("1"*bit_density).to_i(2)
    end

    def shift(input)
      input.ljust(desired_length, '0')
    end

    def search
      shift(@input.scan(/./).map{ |c| bin_chr(c) }.join)
    end

    def mask_chr(chr)
      if chr == '?'
        raise "wildcards not allowed" unless Packetman.config.allow_wildcards
        0
      else
        radix_mask
      end.to_s(2).rjust(bit_density, '0')
    end

    def bin_chr(chr)
      if chr == '?'
        raise "wildcards not allowed" unless Packetman.config.allow_wildcards
        chr = '0'
      end

      if @radix
        chr.to_i(@radix)
      else
        chr.ord
      end.to_s(2).rjust(bit_density, '0')
    end

    def mask_hex
      hex_encode(mask)
    end

    def search_hex
      hex_encode(search)
    end

    def hex_encode(bin_str)
      bin_str.reverse.scan(/.{1,4}/).map{ |chunk| chunk.reverse.to_i(2).to_s(16) }.reverse.join.scan(/.{1,8}/).map{ |hex| hex.prepend('0x') }
    end

    def full_bit_length(num, radix=nil)
      return num.to_i(radix).to_s(radix).length * bit_density(radix) if radix
      
      case num
      when /^0x/
        $'.length * bit_density(16)
      when /^0b/
        $'.length * bit_density(2)
      else
        nil
      end
    end

    def start_byte(position)
      "#{Packetman.config.payload_query} + #{(Packetman.config.offset + position)/8}"
    end

    def to_s
      clauses = []
      position = 0
      search_hex.zip(mask_hex).each_with_index do |(hex_search, hex_mask),i|
        search_bit_length = full_bit_length(hex_search)
        clauses << "#{Packetman.config.transport}[#{start_byte(position)}:#{search_bit_length/8}] & #{hex_mask} = #{hex_search}"
        position += search_bit_length
      end

      clauses.join(' && ')
    end
  end
end
