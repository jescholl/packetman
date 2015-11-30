# Packetman

Advanced tcpdump and Wireshark filter string generator.

[![Gem Version](https://badge.fury.io/rb/packetman.svg)](http://badge.fury.io/rb/packetman)
[![Test Coverage](https://codeclimate.com/github/jescholl/packetman/badges/coverage.svg)](https://codeclimate.com/github/jescholl/packetman/coverage)
[![Inline docs](http://inch-ci.org/github/jescholl/packetman.svg?branch=master)](http://inch-ci.org/github/jescholl/packetman)
[![Circle CI](https://circleci.com/gh/jescholl/packetman.svg?style=svg)](https://circleci.com/gh/jescholl/packetman)
[![Code Climate](https://codeclimate.com/github/jescholl/packetman/badges/gpa.svg)](https://codeclimate.com/github/jescholl/packetman)

Packetman is a packet capture filter generator modeled after [Wireshark's String-Matching Capture Filter Generator](https://www.wireshark.org/tools/string-cf.html) but with a lot more features allowing much finer control over the packets you see.

Features:
  * String-matching (just like Wireshark's tool)
  * bit-string matching
  * hex-string matching
  * easy masking through `?` wildcard characters
  * offsets in bits or bytes
  * use header field name instead of manual offsets
  * application specific queries
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

    $ packetman -h
    
    Usage: packetman [OPTIONS] FILTER_STRING
        -p, --protocol PROTO             Transport Protocol (tcp,udp,icmp)
        -t, --transport                  OFFSET starts at transport header instead of data payload
        -r, --radix RADIX                Treat FILTER_STRING as RADIX instead of String
        -o, --offset OFFSET              Offset in bits
        -b, --byte-offset                Use 8-bit bytes instead of bits for offset
        -w, --wildcard [CHARACTER=?]     Treat CHARACTER as single-character wildcard
        -v, --version                    Show version

Create and use a filter string to capture all HTTP GET requests to `/foo/bar`

    $ sudo tcpdump -nA `packetman GET /foo/bar`
    tcpdump: data link type PKTAP
    tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
    listening on pktap, link-type PKTAP (Packet Tap), capture size 262144 bytes
    16:49:04.516409 IP 127.0.0.1.54662 > 127.0.0.1.80: Flags [P.], seq 1488105913:1488105994, ack 1397163988, win 4121, options [nop,nop,TS val 875380202 ecr 2751916352], length 81: HTTP: GET /foo/bar HTTP/1.1
    .....b....j...E.....@.@..S..
    ..:.....PX...SG......75.....
    4-=....@GET /foo/bar HTTP/1.1
    Host: localhost
    User-Agent: curl/7.43.0
    Accept: */*

Hexadecimal string with wildcards

    $ packetman -r 16 -w '?' "A8C401???C200A"
    tcp[((tcp[12:1] & 0xf0) >> 2) + 0:4] & 0xffffff00 = 0xa8c40100 && tcp[((tcp[12:1] & 0xf0) >> 2) + 4:2] & 0x0fff = 0x0c20 && tcp[((tcp[12:1] & 0xf0) >> 2) + 6:1] & 0xff = 0x0a

Base 4 string with wildcards and offset beginning at start of the TCP header

    $ packetman -t -o 3 -r 4 -w i 1223iiii2212
    tcp[0:4] & 0x1fe01fe0 = 0x0d6014c0

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jescholl/packetman.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

