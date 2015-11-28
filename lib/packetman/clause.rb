module Packetman
  class Clause
    include ConfigMethods

    attr_accessor :search, :mask, :offset

    def initialize(search, mask, offset)
      self.search = search
      self.mask = mask
      self.offset = offset
    end

    def start_byte(start_bit)
      "#{config.payload_query} + #{(config.offset_bits + start_bit)/8}"
    end

    def data_address(start_bit, data_bits)
      "#{config.transport}[#{start_byte(start_bit)}:#{data_bits/8}]"
    end

    def to_s
      "#{data_address(offset, Filter.bit_length(search))} & #{mask} = #{search}"
    end

  end
end
