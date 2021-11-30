require 'spec_helper'

module Packetman
  describe "integration" do
    before(:each) { Packetman.config.wildcard = '?' }
    context "with varying offsets" do
      let (:compose) {Packetman::Filter.new("A")}
      describe "the search and mask" do
        it "should match the input, offset from 1-7" do
          (1..7).each do |offset|
            Packetman.config.offset = offset
            parts = compose.to_s.match(/\] & (?<mask>[0-9a-fx]+) = (?<search>[0-9a-fx]+)/)

            expect(parts['search'].to_i(16)).to eq("A".ord << 16-8-offset)
            expect(parts['mask'].to_i(16)).to eq("11111111".to_i(2) << 16-8-offset)
          end

        end

        it "should match the input, offset for 0 and 8" do
          [0,8].each do |offset|
            Packetman.config.offset = offset
            parts = compose.to_s.match(/\] & (?<mask>[0-9a-fx]+) = (?<search>[0-9a-fx]+)/)

            expect(parts['search'].to_i(16)).to eq("A".ord)
            expect(parts['mask'].to_i(16)).to eq("11111111".to_i(2))
          end

        end
      end
    end
    context "with 5 bit offset" do

      let (:compose) { Packetman::Filter.new("00??1010?111?00010101??10101010?????1010111110???111110101001111010101??????????10100101010100011????1?0") } 
      let (:data)                            {"1011000011010011100001010111101010101100110101111100101111101010011110101010010101001101001010101000110110100101"}

      before(:each) do
        Packetman.config.offset = 5
        Packetman.config.radix = 2
      end

      describe "the raw data" do

        it 'should match the binary sample' do
          compose.search_hex.zip(compose.mask_hex, compose.hex_encode(data)).each do |search, mask, data|
            expect((data.to_i(16) & mask.to_i(16)).to_s(2)).to eq(search.to_i(16).to_s(2))
          end
        end

        it "should also match with 13 bit offset" do
          Packetman.config.offset = 13
          compose.search_hex.zip(compose.mask_hex, compose.hex_encode(data)).each do |search, mask, data|
            expect((data.to_i(16) & mask.to_i(16)).to_s(2)).to eq(search.to_i(16).to_s(2))
          end
        end

        it "should not match with 4 bit offset" do
          Packetman.config.offset = 4
          compose.search_hex.zip(compose.mask_hex, compose.hex_encode(data)).each do |search, mask, data|
            expect((data.to_i(16) & mask.to_i(16)).to_s(2)).not_to eq(search.to_i(16).to_s(2))
          end
        end

      end
    end

    context "with 0 bit offset" do

      let (:compose) { Packetman::Filter.new("00??1010?111?00010101??10101010?????1010111110???111110101001111010101??????????10100101010100011????1?0") }
      let (:data)                            {"00011010011100001010111101010101100110101111100101111101010011110101010010101001101001010101000110110100"}

      before(:each) do
        Packetman.config.offset = 0
        Packetman.config.radix = 2
      end

      describe "the raw data" do
        it "should match the binary sample" do
          compose.search_hex.zip(compose.mask_hex, compose.hex_encode(data)).each do |search, mask, data|
            expect((data.to_i(16) & mask.to_i(16)).to_s(2)).to eq(search.to_i(16).to_s(2))
          end
        end

        it "should also match with 8 bit offset" do
          Packetman.config.offset = 8
          compose.search_hex.zip(compose.mask_hex, compose.hex_encode(data)).each do |search, mask, data|
            expect((data.to_i(16) & mask.to_i(16)).to_s(2)).to eq(search.to_i(16).to_s(2))
          end
        end

        it "should also match with 1 byte offset" do
          Packetman.config.offset = 1
          Packetman.config.offset_type = :bytes
          compose.search_hex.zip(compose.mask_hex, compose.hex_encode(data)).each do |search, mask, data|
            expect((data.to_i(16) & mask.to_i(16)).to_s(2)).to eq(search.to_i(16).to_s(2))
          end
        end

        it "should not match with 5 bit offset" do
          Packetman.config.offset = 5
          compose.search_hex.zip(compose.mask_hex, compose.hex_encode(data)).each do |search, mask, data|
            expect((data.to_i(16) & mask.to_i(16)).to_s(2)).not_to eq(search.to_i(16).to_s(2))
          end
        end

      end
    end

    context 'with a 92 bit input string and 4 bit offset' do
      describe 'the output string' do

        let (:compose) { Packetman::Filter.new("00??1010?111?00010101??10101010?????1010111110???111110101001111010101??????????101001010101") }
        before(:each) {
          Packetman.config.offset = 4
          Packetman.config.radix = 2
        }

        it 'should match the regex' do
          hex_chars = "0-9a-fx"
          data_address = "\\[[\\(\\[0-9a-z\:& \\>+\\]\\)]+:\\d+\\]"
          clause = "\\w+#{data_address} & [#{hex_chars}]+ = [#{hex_chars}]+"
          regex = /(#{clause}( &&)? )+/

          expect(compose.to_s).to match(regex)
        end

      end
    end

    context 'with a dns query' do
      describe 'the output string' do

        let (:compose) { Packetman::Filter.new("www.foobar.bazbat.com") }
        before(:each) {
          Packetman.config.application_override("dns")
        }

        it 'should match the regex' do
          hex_chars = "0-9a-fx"
          data_address = "\\[[\\(\\[0-9a-z\:& \\>+\\]\\)]+:\\d+\\]"
          clause = "\\w+#{data_address} & [#{hex_chars}]+ = [#{hex_chars}]+"
          regex = /(#{clause}( &&)? )+/

          expect(compose.to_s).to match(regex)
        end

        it 'should respond correctly' do
          correct_response = "udp[21:4] & 0xffffff00 = 0x77777700 && udp[25:4] & 0xffffffff = 0x666f6f62 && udp[29:4] & 0xffff00ff = 0x61720062 && udp[33:4] & 0xffffffff = 0x617a6261 && udp[37:4] & 0xff00ffff = 0x7400636f && udp[41:1] & 0xff = 0x6d"

          expect(compose.to_s).to eq(correct_response)
        end

      end
    end

  end
end
