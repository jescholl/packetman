module Packetman
  class Table
    attr_accessor :width, :separator, :labels, :sizes, :cols

    def initialize(labels, sizes, cols = 32)
      @cols = cols
      @separator = '|'
      @labels = labels
      @sizes = sizes
      #FIXME this needs to be unhardcoded
      @query = 8
    end

    def valid?
      if @sizes && @labels && 
        @sizes.length == @labels.length &&
        @sizes.inject(&:+) % @cols == 0
        true
      else
        false
      end
    end

  end
end
