require 'spec_helper'

describe Packetman::Config do
  describe '#new' do
    context 'with no parameters' do
      let(:options) { Packetman::Config.new }
      it 'has default settings' do
        expect(options.transport).not_to be_nil
        expect(options.application).not_to be_nil
        expect(options.offset).not_to be_nil
        expect(options.offset_units).not_to be_nil
        expect(options.offset_type).not_to be_nil
      end
    end

    context 'with a hash parameter' do
      let(:options) { Packetman::Config.new(transport: 'udp', offset: 13, offset_units: :bits, offset_type: 'transport') }
      it 'accepts settings' do
        expect(options.transport).to eq('udp')
        expect(options.offset).to eq(13)
        expect(options.offset_units).to eq(:bits)
        expect(options.offset_type).to eq('transport')
      end
    end
  end
end

