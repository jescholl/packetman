require 'yaml'
require "packetman/version"
require "packetman/config"
require "packetman/table"
require "packetman/compose"

module Packetman
  class << self

    def config
      @config ||= Config.new
    end

    def config!
      @config = Config.new
    end

    def user_input(prompt)
      puts prompt
      gets
    end
  
    def hex_encode(input)
      input = input.to_s(2) if input.kind_of? Integer

      # convert binary string to an array of 32bit hex "strings"
      # multiple reversing ensures we scan from the right, but end up with properly ordered strings/array
      input.reverse.scan(/.{1,4}/).map{ |chunk| chunk.reverse.to_i(2).to_s(16) }.reverse.join.scan(/.{1,8}/).map{ |hex| hex.prepend('0x') }
    end

    def hex_to_bin(hexnum)
      hexnum.to_i(16).to_s(2).rjust(hexnum.length*4, '0')
    end

    def str_to_bin(input_str)
      #pass through hex first to preserve preceding zeros
      input_str.scan(/./).map{ |c| c.ord.to_s(16) }.join.to_i(16).to_s(2)
    end

    def testing(input)
  
      if input =~ /^0b([01\?]+)$/i
        match = $1
        search = hex_encode(match.gsub('?', '0').to_i(2))
        mask = hex_encode(match.gsub('0', '1').gsub('?', '0').to_i(2))
      elsif input =~ /^0x([0-9a-f\?]+)$/i
        match = $1
        search = hex_encode(hex_to_bin(match.gsub('?', '0')))
        mask = hex_encode(hex_to_bin(match.gsub(/[^\?]/, 'f').gsub('?', '0')))
      else
        match = input
        search = hex_encode(match)
        mask = []
        mask.fill(nil, 0, search.length)
      end
  
      mask.zip(search)
  
    end

    def compose2(input, offset)
      octet_offset = offset % 8
      first_octet  = offset / 8

      output = []
      testing(input).each.with_index do |(mask,search),i|
        puts mask
        p search
        puts search
        #NOTE with the .to_f).ceil it increments properly, but it should never go above 4, and it does currently
        # also incrementing offset doesn't do anything, maybe look at bit shifting?
        # I left off playing with compose2 and testing
        # Packetman.compose2("0b10011011000111100000011110110001", 2)
        #
        # IDEA
        # figure out how big the output string is (in octets), then pad to the right (<<) to fill, and unpad (>>) according to octet_offset
        num_octets = ((octet_offset + search.to_i(16).to_s(2).length) / 8.to_f).ceil
        output << "(#{Packetman.config.transport}[#{first_octet + i*4}:#{num_octets}]#{mask ? " & #{mask}" : '' }) = #{search}"
      end
  
      output.join(' && ')
    end

    def byte_length(number)
      (number.bit_length/8.to_f).ceil
    end

    def compose3(input, offset)
      octet_offset = offset % 8
      first_octet  = offset / 8
  
      if input =~ /^0b([01\?]+)$/i
        puts "binary"
        match = $1
        bit_length = ((match.length + octet_offset) / 8.to_f).ceil
        mask = match.gsub('?', '0').gsub('0', '1').rjust(bit_length, '0')
        search = match.gsub('?', '0').rjust(bit_length, '0')
        
      elsif input =~ /^0x([0-9a-f\?]+)$/i
        puts "hex"
        match = $1
        mask = hex_to_bin(match.gsub('?', '0'))
        puts "#{mask} = #{match}.gsub(/[^\?]/, 'F').gsub('?', '0').to_i(16)"
        search = hex_to_bin(input.gsub('?', '0'))
      #  match = $1
      #  search = match.gsub('?', '0').to_i(16)
      #  num_octets = ((match.length*4 + octet_offset) / 8.to_f).ceil
      #  mask = hex_encode(match.gsub(/[^\?]/, 'f').gsub('?', '0').to_i(16))
      else
        puts "string"
        search = str_to_bin(input)
        mask = ("1"*search.bit_length)
      #  match = input
      #  search = match
      #  num_octets = ((match.length*8 + octet_offset) / 8.to_f).ceil
      #  mask = []
      #  #FIXME I just broke the mask here
      #  mask.fill(nil, 0, search.length)
      end

      # only for strings?
      # won't work
      # (num_bytes   - offset - search.bit_length)

      #if octet_offset != 0
      #  search = search << octet_offset
      #  mask = mask << octet_offset
      #end


      #bits_needed = search.bit_length + octet_offset
      #num_octets = (mask.bit_length/8.to_f).ceil
      #p num_octets
      #right_pad = num_octets * 8 - bits_needed
      #p right_pad

#      search = search << right_pad
      p search
      search = hex_encode(search)
      p search.map{ |c| c.to_i(16).to_s(2) }.join
 #     mask = mask << right_pad
      p mask
      mask = hex_encode(mask)
      p mask.map{ |c| c.to_i(16).to_s(2) }.join
  
      output = []
      search.zip(mask).each_with_index do |(search,mask),i|
        num_octets = (mask.to_i(16).bit_length/8.to_f).ceil


        #p mask
        #p mask.class
        #p mask.to_s(2)
        #if octet_offset != 0
        #  shift_width = (num_octets*8 - octet_offset) - mask.bit_length
        #  p shift_width
        #  mask = mask << shift_width
        #end
        #p mask.to_s(2)


        query = "#{Packetman.config.transport}[#{first_octet + i*4}:#{num_octets}]"
        query = "(#{query} & #{mask.to_i(16).to_s(2)})"
        #query = "(#{query} <<  #{8 - octet_offset})" if octet_offset != 0
        query = "#{query} = #{search.to_i(16).to_s(2)}"
        output << query
        #output << "(#{Packetman.config.transport}[#{first_octet + i*4}:#{(mask.to_i(16).bit_length/8.to_f).ceil}] & #{mask}) #{octet_offset > 1 ? "<< #{octet_offset} " : ""}= #{search}"
        #output << "(#{Packetman.config.transport}[#{first_octet + i*4}:#{num_octets}]#{mask ? " & #{mask.to_i(16).to_s(2)}" : '' }) = #{search.to_i(16).to_s(2)}"
      end
  
      output.join(' && ')
    end

    def compose_string(input, offset)
      octet_offset = offset % 8
      first_octet  = offset / 8
  
      if input =~ /^0b([01\?]+)$/i
        match = $1
        search = hex_encode(match.gsub('?', '0').to_i(2))
        num_octets = (match.length + octet_offset) / 8
        puts "#{num_octets} = ((#{match.length} + #{octet_offset}) / 8.to_f).ceil"
        mask = hex_encode(match.gsub('0', '1').gsub('?', '0').to_i(2))
      elsif input =~ /^0x([0-9a-f\?]+)$/i
        #FIXME the left padding doesn't work, to_i strips it, I need to convert all of the hex stuff to a class
        match = $1
        p match
        search = hex_encode(match.gsub('?', '0').to_i(16))
        p search
        num_octets = ((match.length*4 + octet_offset) / 8.to_f).ceil
        p num_octets
        mask = hex_encode(match.gsub(/[^\?]/, 'f').gsub('?', '0').to_i(16))
        p mask
      else
        match = input
        search = hex_encode(match)
        num_octets = ((match.length*8 + octet_offset) / 8.to_f).ceil
        mask = []
        mask.fill(nil, 0, search.length)
      end
  
      output = []
      search.zip(mask).each_with_index do |(search,mask),i|
      output << "(#{Packetman.config.transport}[#{first_octet + i*4}:#{num_octets}]#{mask ? " & #{mask}" : '' }) = #{search}"
      end
  
      output.join(' && ')
    end

    def protocol_table
      # draw header row
      output = h_bar = sprintf "%s%s%s\n", config.table_delim, "-"*(config.table_cols*2 + config.table_cols*config.table_delim.length - 1), config.table_delim
      output += sprintf "#{config.table_delim}%02d"*config.table_cols + "#{config.table_delim}\n", *[*0..(config.table_cols-1)]
      output += h_bar
      tmp_output = config.table_delim

      # draw the rest of the rows
      # NOTE: each row must have a cell break at `config.table_cols` or output errors will occur
      config.protocols[config.transport][:table].each do |label, size|
      #labels.zip(sizes).each do |label, size|
        cell_size = size*3 - 1
        tmp_output += sprintf "%.#{cell_size}s%s", label.center(cell_size), config.table_delim

        if tmp_output.length == config.table_cols*2 + config.table_cols*config.table_delim.length + 1
          output += tmp_output + "\n"
          output += h_bar
          tmp_output = config.table_delim
        end
      end
      output
    end
  end
end

#FIXME add something to select header fields rather than needing to count, or a header map
