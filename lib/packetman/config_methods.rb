module Packetman
  module ConfigMethods
    def self.included(base)
      base.extend(self)
    end

    def config
      Packetman.config
    end

    def protocols
      config.protocols
    end
  end
end
