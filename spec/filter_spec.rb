require 'spec_helper'

module Packetman
  describe Filter do
    before(:each) do
      Packetman.config.offset = 5
    end
    context 'with a binary string with wildcards' do
      let (:compose) { Packetman::Filter.new("00??10100011???????"){ |config| config.radix = 2 } }

      describe '#desired_length' do
        it 'should be divisible by 8 when added to offset' do
          expect((compose.desired_length + Packetman.config.offset) % 8).to eq(0)
        end
      end
    end

    context 'with invalid radix data' do
      let (:compose) { Packetman::Filter.new("00??10200011???????"){ |config| config.radix = 2 } }

      describe '#to_s' do
        it 'should raise an exception' do
          expect{compose.to_s}.to raise_error{/invalid character/}
        end
      end
    end

    context 'with a 4 character string' do

      let(:compose) { Packetman::Filter.new('test') }
      describe '#bit_density' do
        it 'should be 8' do
          expect(Filter.bit_density).to eq(8)
        end
      end

      describe '#to_s' do
        it 'should create one clause' do
          expect(compose.to_s).not_to match(/&&/)
        end
      end

    end

    context 'with a 3 character string' do

      let(:compose) { Packetman::Filter.new('foo') }

      describe '#to_s' do
        it 'should create two clauses' do
          expect(compose.to_s.split('&&').length).to be(2)
        end
      end

    end

    context 'with an 11 character string' do
      before(:each) { Packetman.config.offset = 0 }
      let(:compose) { Packetman::Filter.new('12345678901') }

      describe '#to_s' do
        it 'last offset should be 10' do
          expect(compose.to_s.split('&&').last.strip).to eq('tcp[((tcp[12:1] & 0xf0) >> 2) + 10:1] & 0xff = 0x31')
        end
      end
    end

    context 'with a long string' do
      let(:compose) { Packetman::Filter.new('this is a really long test string') }
      describe '#to_s' do
        it 'should create 9 clauses' do
          expect(compose.to_s.split('&&').length).to be(9)
        end
      end

    end

    context 'with short hex' do
      before(:each) { Packetman.config.radix = 16 }
      let(:compose) { Packetman::Filter.new('abc123') }
      describe '#bit_density' do
        it 'should be 4' do
          expect(Filter.bit_density).to eq(4)
        end
      end
    end

    context 'with short binary' do
      before(:each) { Packetman.config.radix = 2 }
      let(:compose) { Packetman::Filter.new('10101') }
      describe '#bit_density' do
        it 'should be 1' do
          expect(Filter.bit_density).to eq(1)
        end
      end
    end

  end
end
