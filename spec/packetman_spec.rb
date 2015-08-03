require 'spec_helper'

describe Packetman do
  it 'has a version number' do
    expect(Packetman::VERSION).not_to be nil
  end

  describe '.hex_encode' do
    context 'with a string' do
      let(:short) { 'H' }
      let(:medium) { 'Help' }
      let(:long) { 'Help it burns!' }
      it 'works with less than 32 bits' do
        expect(Packetman.hex_encode(short)).to eq(["0x48"])
      end
      it 'works with 32 bits' do
        expect(Packetman.hex_encode(medium)).to eq(["0x48656c70"])
      end
      it 'works with more than 32 bits' do
        expect(Packetman.hex_encode(long)).to eq(["0x48656c70", "0x20697420", "0x6275726e", "0x7321"])
      end
    end
    context 'with an integer' do
      let(:short) { 123 }
      let(:medium) { 2882343476 }
      let(:long) { 50707717374670895242426 }
      it 'works with less than 32 bits' do
        expect(Packetman.hex_encode(short)).to eq(["0x7b"])
      end
      it 'works with 32 bits' do
        expect(Packetman.hex_encode(medium)).to eq(["0xabcd1234"])
      end
      it 'works with more than 32 bits' do
        expect(Packetman.hex_encode(long)).to eq(["0xabcdef12", "0x34321fed", "0xcba"])
      end
    end
  end

  #  it 'calculates binary wildcard strings correctly' do
  #    # "(tcp[13:4] & 0xfff0) = 0x1010"
  #    Packetman.compose_string("0b??101?", 106) =~ /& (0x[0-9a-f]+)\) = (0x[0-9a-f]+)$/i
  #    mask, search = $1.to_i(16), $2.to_i(16)
  #
  #    test_strings = [
  #      0b11111011,
  #      0b11111010,
  #      0b11101011,
  #      0b11101010,
  #      0b11011011,
  #      0b11011010,
  #      0b11001011,
  #      0b11001010
  #    ]
  #
  #    success_strings = 0 
  #    test_strings.each do |raw|
  #      if raw & mask == search
  #        success_strings += 1
  #      end
  #     end
  #
  #    expect(success_strings).to eq(test_strings.length)
  #  end
  #
  #  it 'calculates hex wildcard strings correctly' do
  #    # "(tcp[13:5] & 0xff00ffff) = 0xab00acff"
  #    #
  #  end
  #
  #def 
  #    Packetman.compose_string("0xab??acff", 106) =~ /& (0x[0-9a-f]+)\) = (0x[0-9a-f]+)$/i
  #    mask, search, $1.to_i(16), $2.to
end

