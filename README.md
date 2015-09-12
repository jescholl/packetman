# Packetman

Advanced tcpdump and Wireshark capture generator.

[![Code Climate](https://codeclimate.com/github/jescholl/packetman/badges/gpa.svg)](https://codeclimate.com/github/jescholl/packetman) [![Test Coverage](https://codeclimate.com/github/jescholl/packetman/badges/coverage.svg)](https://codeclimate.com/github/jescholl/packetman/coverage) [![Circle CI](https://circleci.com/gh/jescholl/packetman.svg?style=svg)](https://circleci.com/gh/jescholl/packetman)

Packetman is an all-purpose capture generator modeled after [Wireshark's String-Matching Capture Filter Generator](https://www.wireshark.org/tools/string-cf.html) but with a lot more features allowing much finer control over the packets you see.

Features: (**currently in development)
  * String-matching (just like Wireshark's tool)
  * bit-string matching
  * hex-string matching
  * easy masking through `?` wildcard characters
  * offsets in bits or bytes*
  * use header field name instead of manual offsets*
  * application specific queries*
  * built-in header reference tables

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'packetman'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install packetman

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jescholl/packetman.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

