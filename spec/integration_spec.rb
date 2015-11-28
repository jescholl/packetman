require 'spec_helper'

module Packetman
  describe "integration" do
    before(:each) { Packetman.config.wildcard = '?' }
    context "with 5 bit offset" do

      let (:compose) { Packetman::Filter.new("00??1010?111?00010101??10101010?????1010111110???111110101001111010101??????????10100101010100011????1?0") }
      let (:data)                            {"00011010011100001010111101010101100110101111100101111101010011110101010010101001101001010101000110110100101"}

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
          Packetman.config.use_bytes = true
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

        it 'should have have a 32 bit first clause' do
          clause = compose.to_s.split('&&')[0]
          search = clause.split('=').last.strip
          expect(Filter.bit_length(search)).to eq(32)
        end

        it 'should have have a 32 bit second clause' do
          clause = compose.to_s.split('&&')[1]
          search = clause.split('=').last.strip
          expect(Filter.bit_length(search)).to eq(32)
        end

        it 'should have have a 16 bit third clause' do
          clause = compose.to_s.split('&&')[2]
          search = clause.split('=').last.strip
          expect(Filter.bit_length(search)).to eq(16)
        end

        it 'should have have a 8 bit third clause' do
          clause = compose.to_s.split('&&')[3]
          search = clause.split('=').last.strip
          expect(Filter.bit_length(search)).to eq(8)
        end

        it 'should match the regex' do
          hex_chars = "0-9a-fx"
          data_address = "\\[[\\(\\[0-9a-z\:& \\>+\\]\\)]+:\\d+\\]"
          clause = "\\w+#{data_address} & [#{hex_chars}]+ = [#{hex_chars}]+"
          regex = /(#{clause}( &&)? )+/

          expect(compose.to_s).to match(regex)
        end

      end
    end

  end
end
