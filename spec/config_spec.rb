require 'spec_helper'

describe Packetman::Config do
  describe '#new' do
    it 'has default settings' do
      expect(Packetman.config.transport).not_to be_nil
      expect(Packetman.config.offset).not_to be_nil
    end
  end

  describe '#parse_opts' do
    it 'should fail when given no filter string' do
      overwrite_constant :ARGV, []
      expect{Packetman.config.parse_opts}.to raise_error{"Invalid command line arguments"}
    end

    it 'should return the filter string' do
      overwrite_constant :ARGV, %w{ foo }
      expect(Packetman.config.parse_opts).to eq('foo')
    end

    it 'should respect -t' do
      overwrite_constant :ARGV, %w{ -t foo }
      expect{Packetman.config.parse_opts}.to change{Packetman.config.start_with_transport}.from(nil).to(true)
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
      expect{Packetman.config.parse_opts}.to change{Packetman.config.use_bytes}.from(nil).to(true)
    end

    it 'should respect -w' do
      overwrite_constant :ARGV, %w{ -w foo }
      Packetman.config.parse_opts
      expect(Packetman.config.allow_wildcards).to eq(true)
    end
  end
end

