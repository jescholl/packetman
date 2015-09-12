#!/usr/bin/env ruby

require 'packetman'

Packetman.config.parse_opts

puts Packetman.compose
