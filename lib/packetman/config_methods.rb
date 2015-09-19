module Packetman
  module ConfigMethods
    def self.included(base)
      base.extend(self)
    end

    def config
      Packetman.config
    end
  end
end
