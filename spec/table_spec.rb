require 'spec_helper'

module Packetman
  describe Table do
    let(:table){ Packetman::Table.new() }
    describe '#to_s' do

      context 'with tcp data' do
        before(:each){ Packetman.config.transport = 'tcp' }
        it 'should print a table with every line the same length' do
          expect(table.to_s.split("\n").map(&:length).uniq.size).to eq(1)
        end
      end

      context 'with udp data' do
        before(:each){ Packetman.config.transport = 'udp' }
        it 'should print a table with every line the same length' do
          expect(table.to_s.split("\n").map(&:length).uniq.size).to eq(1)
        end
      end
    end

    it 'should have 32 columns' do
      expect(table.to_s.split("\n").map)
    end

  end
end
