require 'spec_helper'

describe Packetman::Table do
  let(:table){ Packetman::Table.new() }
  describe '#to_s' do

    it 'should respect custom line_h and line_v characters' do
      table.line_h = 'a'
      table.line_v = 'b'
      expect(table.to_s.split(/\n/).first).to match(/^ba+b$/)
    end

    context 'with tcp data' do
      before(:all){ Packetman.config.transport = 'tcp' }
      it 'should print a table with every line the same length' do
        expect(table.to_s.split("\n").map(&:length).uniq.size).to eq(1)
      end
    end

    context 'with udp data' do
      before(:all){ Packetman.config.transport = 'udp' }
      it 'should print a table with every line the same length' do
        expect(table.to_s.split("\n").map(&:length).uniq.size).to eq(1)
      end
    end
  end

  describe '#line_h=' do
    it 'should fail when given bad input' do
      expect{table.line_h = 'aa'}.to raise_error(/Invalid character/)
      expect{table.line_h = ''}.to raise_error(/Invalid character/)
    end
  end

  describe '#line_v=' do
    it 'should fail when given bad input' do
      expect{table.line_v = 'aa'}.to raise_error(/Invalid character/)
      expect{table.line_v = ''}.to raise_error(/Invalid character/)
    end
  end
  #FIXME each table is right in every way
end
