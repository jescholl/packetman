require 'spec_helper'

module Packetman
  describe Compose do
    let (:compose) { Packetman::Compose.new("00??1010?111?00010101??10101010?????1010111110???111110101001111010101??????????10100101010100011???????", 5, 2) }
    let (:data) {"00011010011100001010111101010101100110101111100101111101010011110101010010101001101001010101000110110100101"}

    describe '#desired_length' do
      it 'should be divisible by 8 when added to @offset' do
        expect((compose.desired_length + compose.offset) % 8).to eq(0)
      end
    end
    context 'with a string' do
      let(:compose) {Packetman::Compose.new('foo', 5) }
      describe '#bit_density' do
        it 'should be 8' do
          expect(compose.bit_density).to eq(8)
        end
      end
    end

    context 'with hex' do
      let(:compose) {Packetman::Compose.new('abc123', 5, 16) }
      describe '#bit_density' do
        it 'should be 4' do
          expect(compose.bit_density).to eq(4)
        end
      end
    end

    context 'with binary' do
      let(:compose) {Packetman::Compose.new('10101', 5, 2) }
      describe '#bit_density' do
        it 'should be 1' do
          expect(compose.bit_density).to eq(1)
        end
      end
    end
  end
end
