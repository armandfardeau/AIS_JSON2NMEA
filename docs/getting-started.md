---
title: Getting Started
---

# Getting Started

## Requirements

- Ruby 3.2+
- RubyGems / Bundler

No external AIS or C++ library is required.

## Installation

Add to your `Gemfile`:

```ruby
gem 'ais_to_nmea'
```

Then run:

```bash
bundle install
```

Or install directly:

```bash
gem install ais_to_nmea
```

## Quick Start

```ruby
require 'ais_to_nmea'

nmea = AisToNmea.to_nmea({
  "MessageID"        => 1,
  "UserID"           => 123456789,
  "Latitude"         => 48.8566,
  "Longitude"        => 2.3522,
  "SpeedOverGround"  => 12.3,
  "CourseOverGround" => 254.8,
  "TrueHeading"      => 255
})

puts nmea
# => !AIVDM,1,1,,A,15M67FC000G?ufbE`FepT@3n00Sa,0*5C
```

## Building from Source

```bash
git clone https://github.com/armandfardeau/AIS_JSON2NMEA.git
cd AIS_JSON2NMEA
bundle install
bundle exec rake spec   # run tests
bundle exec rake build  # build the gem
```

## Supported Platforms

- Linux (x86_64, ARM, etc.)
- macOS (Intel, Apple Silicon)

---

[← Home](index) | [API Reference →](api)
