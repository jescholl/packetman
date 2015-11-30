require 'terminal-table'

module Packetman
  class Table
    include ConfigMethods

    def initialize

      @term_table = Terminal::Table.new(headings: headings, rows: rows, style: style)
    end

    def headings
      [*0..31].map{ |c| "%02d" % c }
    end

    def rows
      protocols[config.transport]['table']
    end

    def style
      { alignment: :center, padding_left: 0, padding_right: 0}
    end

    def to_s
      @term_table.to_s
    end

  end
end
