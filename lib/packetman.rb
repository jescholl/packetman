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
  end
end
