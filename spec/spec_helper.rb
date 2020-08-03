require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'support/constants_helper'
require 'packetman'

RSpec.configure do |config|
  config.include ConstantsHelper

  config.before(:each) do
    overwrite_constant :ARGV, []
  end

  config.after(:each) do
    reset_all_constants
    Packetman.config!
  end

end
