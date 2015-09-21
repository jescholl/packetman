module Packetman
  class Table
    include ConfigMethods

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
      (columns-1).to_s.length
    end

    def horizontal_bar
      line_v + line_h*(table_width - 2) + line_v + "\n"
    end

    def table_width
      columns*(column_width + 1) + 1
    end

    def cell_size(field_size)
      field_size*(column_width + 1) - 1
    end

    def header_row
      line_v + columns.times.map{ |n| sprintf "%0#{column_width}d", n }.join(line_v) + line_v + "\n"
    end

    def to_s
      output = horizontal_bar + header_row + horizontal_bar

      protocols[config.transport]['table'].each do |label, size|
        output += sprintf "%s%.#{cell_size(size)}s", line_v, label.center(cell_size(size))
        if output.split("\n").last.length == (table_width - 1)
          output += line_v + "\n"
          output += horizontal_bar
        end
      end
      output
    end

  end
end
