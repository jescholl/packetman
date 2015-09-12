module Packetman
  class Table
    attr_reader :line_h, :line_v
    attr_accessor :columns

    def initialize(cols = 32)
      @line_v = '|'
      @line_h = '-'
      @columns = cols
    end

    def line_h=(value)
      raise "Invalid character" if value.length != 1
      @line_h = value
    end

    def line_v=(value)
      raise "Invalid character" if value.length != 1
      @line_v = value
    end

    def column_width
      (columns-1).to_s.length + 1
    end

    def horizontal_bar
      line_v + line_h*(table_width - 1) + line_v + "\n"
    end

    def table_width
      columns*column_width
    end

    def cell_size(field_size)
      field_size*column_width - 1
    end

    def to_s
      output = horizontal_bar
      output += line_v + [*0..(columns-1)].map{ |n| "%0#{column_width - 1}d" % n }.join(line_v) + line_v + "\n"
      output += horizontal_bar

      tmp_output = line_v
      Packetman.config.protocols[Packetman.config.transport]['table'].each do |label, size|
        tmp_output += sprintf "%.#{cell_size(size)}s%s", label.center(cell_size(size)), line_v

        if tmp_output.length == (table_width+1)
          output += tmp_output + "\n"
          output += horizontal_bar
          tmp_output = line_v
        end
      end
      output
    end

  end
end
