module Packetman
  class Clause
    include ConfigMethods

    attr_accessor :search, :mask, :start_bit

    def initialize(search, mask, start_bit)
      self.search = search
      self.mask = mask
      self.start_bit = start_bit
    end

    # Address of first byte
    def start_byte
      [config.payload_query, (config.offset_bits + start_bit)/8].compact.join(' + ')
    end

    def num_bytes
      Filter.bit_length(search)/8
    end

    # Full address of the query data (eg. `tcp[0:4]`)
    def data_address
      "#{config.transport}[#{start_byte}:#{num_bytes}]"
    end

    # The whole filter clause fully assembled
    def to_s
      "#{data_address} & #{mask} = #{search}"
    end

  end
end
