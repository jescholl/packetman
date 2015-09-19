require 'spec_helper'

describe Packetman::Config do
  describe '#new' do
    it 'has default settings' do
      expect(Packetman.config.transport).not_to be_nil
      expect(Packetman.config.application).not_to be_nil
      expect(Packetman.config.offset).not_to be_nil
      expect(Packetman.config.offset_units).not_to be_nil
      expect(Packetman.config.offset_type).not_to be_nil
    end
  end

  describe '#parse_opts' do
    it 'should fail when given no filter string' do
      overwrite_constant :ARGV, []
      expect{Packetman.config.parse_opts}.to raise_error{"Incorrect number of command line arguments"}
    end

    it 'should return the filter string' do
      overwrite_constant :ARGV, %w{ foo }
      expect(Packetman.config.parse_opts).to eq('foo')
    end

    it 'should respect -t' do
      overwrite_constant :ARGV, %w{ -t udp foo }
      expect{Packetman.config.parse_opts}.to change{Packetman.config.transport}.from("tcp").to("udp")
    end

    it 'should respect -a' do
      overwrite_constant :ARGV, %w{ -a icmp foo }
      Packetman.config.parse_opts
      expect(Packetman.config.application).to eq('icmp')
    end

    it 'should respect -r' do
      overwrite_constant :ARGV, %w{ -r 123 foo }
      Packetman.config.parse_opts
      expect(Packetman.config.radix).to eq(123)
    end

    it 'should respect -o' do
      overwrite_constant :ARGV, %w{ -o 123 foo }
      Packetman.config.parse_opts
      expect(Packetman.config.offset).to eq(123)
    end

    it 'should respect -b' do
      overwrite_constant :ARGV, %w{ -b foo }
      expect{Packetman.config.parse_opts}.to change{Packetman.config.offset_units}.from("bits").to("bytes")
    end

    it 'should respect -O' do
      overwrite_constant :ARGV, %w{ -O transport foo }
      expect{Packetman.config.parse_opts}.to change{Packetman.config.offset_type}.from("application").to("transport")
    end

    it 'should respect --wildcards' do
      overwrite_constant :ARGV, %w{ --wildcards foo }
      Packetman.config.parse_opts
      expect(Packetman.config.allow_wildcards).to eq(true)
    end

    it 'should respect --no-wildcards' do
      overwrite_constant :ARGV, %w{ --no-wildcards foo }
      Packetman.config.parse_opts
      expect(Packetman.config.allow_wildcards).to eq(false)
    end
  end

  #    context 'with a hash parameter' do
  #      let(:options) { Packetman::Config.new(transport: 'udp', offset: 13, offset_units: :bits, offset_type: 'transport') }
  #      it 'accepts settings' do
  #        expect(options.transport).to eq('udp')
  #        expect(options.offset).to eq(13)
  #        expect(options.offset_units).to eq(:bits)
  #        expect(options.offset_type).to eq('transport')
  #      end
  #    end
end

