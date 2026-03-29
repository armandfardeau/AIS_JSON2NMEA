---
title: Home
---

# AIS JSON to NMEA

Convert AIS (Automatic Identification System) JSON messages into raw NMEA 0183 AIS sentences using a pure Ruby encoder.

## Features

- **Supported AIS Message Types**: 1, 2, 3 (Position Reports), 4 (Base Station Report), 5 (Ship Static Data), 14 (Safety Broadcast Message)
- **Multiple Input Formats**: Ruby Hash or JSON string
- **Valid NMEA Output**: 6-bit encoding, correct fill bits, valid checksums
- **Multi-part Support**: Automatically splits long messages into multiple NMEA sentences
- **Comprehensive Error Handling**: Descriptive exceptions for every failure mode
- **Pure Ruby**: No native extension, no external C++ dependencies

## Documentation

- [Getting Started](getting-started) — Installation and quick start
- [API Reference](api) — Full API documentation
- [Input Formats](input-formats) — Supported message types and field reference
- [Error Handling](error-handling) — Exception types and usage
- [Examples](examples) — Runnable code examples

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
