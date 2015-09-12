require 'spec_helper'

module Packetman
  describe Compose do
    let (:compose) { Packetman::Compose.new("00??1010?111?00010101??10101010?????1010111110???111110101001111010101??????????10100101010100011???????", 2) }
    let (:data) {"00011010011100001010111101010101100110101111100101111101010011110101010010101001101001010101000110110100101"}
    describe 'integration' do
      it 'should match the binary sample' do
        compose.search_hex.zip(compose.mask_hex, compose.hex_encode(data)).each do |search, mask, data|
          expect((data.to_i(16) & mask.to_i(16)).to_s(2)).to eq(search.to_i(16).to_s(2))
        end
      end
    end
  end
end
