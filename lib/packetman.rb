require 'yaml'
require "packetman/version"
require "packetman/config"
require "packetman/config_methods"
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
  end
end
