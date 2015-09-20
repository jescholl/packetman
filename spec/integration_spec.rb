require 'spec_helper'

module Packetman
  describe "integration" do
    context "with 5 bit offset" do
      let (:compose) { Packetman::Compose.new("00??1010?111?00010101??10101010?????1010111110???111110101001111010101??????????10100101010100011????1?0", 2) }
      let (:data)                            {"00011010011100001010111101010101100110101111100101111101010011110101010010101001101001010101000110110100101"}
      before(:each) { Packetman.config.offset = 5 }
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
      let (:compose) { Packetman::Compose.new("00??1010?111?00010101??10101010?????1010111110???111110101001111010101??????????10100101010100011????1?0", 2) }
      let (:data)                            {"00011010011100001010111101010101100110101111100101111101010011110101010010101001101001010101000110110100"}
      before(:each) do
        Packetman.config.offset = 0
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
          Packetman.config.offset_units = "bytes"
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

  end
end
