require 'spec_helper'

module Packetman
  describe Compose do
    before(:each) { Packetman.config.offset = 5 }
    let (:compose) { Packetman::Compose.new("00??10100011???????", 2) }

    describe '#desired_length' do
      it 'should be divisible by 8 when added to offset' do
        expect((compose.desired_length + Packetman.config.offset) % 8).to eq(0)
      end
    end

    context 'with a 4 character string' do

      let(:compose) {Packetman::Compose.new('test') }
      describe '#bit_density' do
        it 'should be 8' do
          expect(compose.bit_density).to eq(8)
        end
      end

      describe '#to_s' do
        it 'should create one clause' do
          expect(compose.to_s).not_to match(/&&/)
        end
      end

    end

    context 'with a 3 character string' do

      let(:compose) {Packetman::Compose.new('foo') }

      describe '#to_s' do
        it 'should create two clauses' do
          expect(compose.to_s.split('&&').length).to be(2)
        end
      end

    end

    context 'with a long string' do
      let(:compose) {Packetman::Compose.new('this is a really long test string') }
      describe '#to_s' do
        it 'should create 9 clauses' do
          expect(compose.to_s.split('&&').length).to be(9)
        end
      end

    end

    context 'with short hex' do
      let(:compose) {Packetman::Compose.new('abc123', 16) }
      describe '#bit_density' do
        it 'should be 4' do
          expect(compose.bit_density).to eq(4)
        end
      end
    end

    context 'with short binary' do
      let(:compose) {Packetman::Compose.new('10101', 2) }
      describe '#bit_density' do
        it 'should be 1' do
          expect(compose.bit_density).to eq(1)
        end
      end
    end
  end
end
