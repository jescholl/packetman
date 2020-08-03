# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'packetman/version'

Gem::Specification.new do |spec|
  spec.name          = "packetman"
  spec.version       = Packetman::VERSION
  spec.authors       = ["Jason Scholl"]
  spec.email         = ["jason.e.scholl@gmail.com"]

  spec.summary       = %q{Advanced tcpdump and Wiresharp filter generator.}
  spec.description   = %q{Simple tool for creating advanced tcpdump queries, because manually writing `tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420` is no fun.}
  spec.homepage      = "https://github.com/jescholl/packetman"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "terminal-table", "~> 1.8"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "simplecov", "~> 0.17"
  spec.add_development_dependency "pry", "~> 0.12"
end
