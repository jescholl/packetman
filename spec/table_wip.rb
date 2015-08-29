require 'spec_helper'

describe Packetman::Table do
  describe '#valid?' do
    let(:table){ Packetman::Table.new(['foo', 'bar'], [8,7], 16) }

    it 'rejects mismatched cols/sizes' do
      expect(table.valid?).to eq(false)
    end

    it 'passes correct values' do
      table.sizes = [8,8]
      expect(table.valid?).to eq(true)
    end
  end
  describe '#print' do
    context 'with mismatched cols/sizes' do
      let(:table){ Packetman::Table.new(['foo', 'bar'], [8,7], 16) }
      it 'raises an error' do
        expect(table.print).to raise_error
      end
    end

    context 'with matched cols/sizes' do
      let(:table){ Packetman::Table.new(['foo', 'bar'], [8,8], 16) }
      it 'returns a table string' do
        expect(table.print.split("\n").map(&:length).uniqh).to eq([16])
      end
    end
  end
  #FIXME each table is right in every way
end
