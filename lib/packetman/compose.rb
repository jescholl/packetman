module Packetman
  class Compose
    include ConfigMethods

    def initialize(input, radix=config.radix)
      @input = input
      @radix = radix
    end

    def desired_length
      ((@input.length + config.offset)/8.to_f).ceil*8 - config.offset
    end

    def bit_density(radix=@radix)
      (radix.nil?) ? 8 : Math.log2(radix).to_i
    end

    def mask_bits
      shift(@input.scan(/./).map{ |c| mask_chr(c) }.join)
    end

    def radix_mask
      ("1"*bit_density).to_i(2)
    end

    def shift(input)
      input.ljust(desired_length, '0')
    end

    def search_bits
      shift(@input.scan(/./).map{ |c| bin_chr(c) }.join)
    end

    def mask_chr(chr)
      if chr == '?'
        raise "wildcards not allowed" unless config.allow_wildcards
        0
      else
        radix_mask
      end.to_s(2).rjust(bit_density, '0')
    end

    def bin_chr(chr)
      if chr == '?'
        raise "wildcards not allowed" unless config.allow_wildcards
        chr = '0'
      end

      if @radix
        chr.to_i(@radix)
      else
        chr.ord
      end.to_s(2).rjust(bit_density, '0')
    end

    def mask_hex
      hex_encode(mask_bits)
    end

    def search_hex
      hex_encode(search_bits)
    end

    def hex_encode(bin_str)
      bin_str.reverse.scan(/.{1,4}/).map{ |chunk| chunk.reverse.to_i(2).to_s(16) }.reverse.join.scan(/.{8}|.{4}|.{2}/).map{ |hex| hex.prepend('0x') }
    end

    def bit_length(num)
      case num
      when /^0x/
        $'.length * bit_density(16)
      when /^0b/
        $'.length * bit_density(2)
      else
        nil
      end
    end

    def start_byte(bit_position)
      [config.payload_query, (config.offset + bit_position)/8].compact.join(' + ')
    end

    def data_address(start_bit, bit_length)
      "#{config.transport}[#{start_byte(start_bit)}:#{bit_length/8}]"
    end

    def to_s
      search_hex.zip(mask_hex).map.with_index do |(search, mask),i|
        "#{data_address(i*32, bit_length(search))} & #{mask} = #{search}"
      end.join(' && ')
    end
  end
end
