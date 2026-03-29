---
title: Examples
---

# Examples

All examples are in the [`examples/`](https://github.com/armandfardeau/AIS_JSON2NMEA/tree/main/examples) directory. Run any one with:

```bash
bundle exec ruby -Ilib examples/01_position_reports.rb
```

Run all examples:

```bash
for f in examples/[0-9][0-9]_*.rb; do bundle exec ruby -Ilib "$f"; done
```

---

## 01 — Position Reports (Types 1, 2, 3)

```ruby
require 'ais_to_nmea'

# Type 1 — default
puts AisToNmea.to_nmea({
  "MessageID"        => 1,
  "UserID"           => 123456789,
  "Latitude"         => 48.8566,
  "Longitude"        => 2.3522,
  "SpeedOverGround"  => 12.3,
  "CourseOverGround" => 254.8,
  "TrueHeading"      => 255
})

# Type 2 — New York
puts AisToNmea.to_nmea({
  "MessageID"        => 2,
  "UserID"           => 111111111,
  "Latitude"         => 40.7128,
  "Longitude"        => -74.0060,
  "SpeedOverGround"  => 15.8,
  "CourseOverGround" => 45.5,
  "TrueHeading"      => 46
})

# Type 3 — Tokyo, stationary, heading not available (511)
puts AisToNmea.to_nmea({
  "MessageID"        => 3,
  "UserID"           => 222222222,
  "Latitude"         => 35.6762,
  "Longitude"        => 139.6503,
  "SpeedOverGround"  => 0.0,
  "CourseOverGround" => 0.0,
  "TrueHeading"      => 511
})
```

---

## 02 — Input Formats

```ruby
require 'ais_to_nmea'

# Ruby Hash
puts AisToNmea.to_nmea({
  "MessageID"        => 1,
  "UserID"           => 333333333,
  "Latitude"         => 60.1699,
  "Longitude"        => 18.6414,
  "SpeedOverGround"  => 10.5,
  "CourseOverGround" => 90.0,
  "TrueHeading"      => 90
})

# JSON string
puts AisToNmea.to_nmea(<<~JSON)
  {
    "MessageID": 1,
    "UserID": 987654321,
    "Latitude": 51.5074,
    "Longitude": -0.1278,
    "SpeedOverGround": 8.5,
    "CourseOverGround": 123.4,
    "TrueHeading": 120
  }
JSON
```

---

## 03 — Ship Static Data (Type 5)

```ruby
require 'ais_to_nmea'

puts AisToNmea.to_nmea({
  "MessageID"              => 5,
  "UserID"                 => 636024245,
  "IMONumber"              => 9876543,
  "CallSign"               => "FRA1234",
  "Name"                   => "TEST VESSEL",
  "ShipType"               => 70,
  "Dimension"              => { "A" => 50, "B" => 20, "C" => 5, "D" => 5 },
  "FixType"                => 1,
  "Eta"                    => { "Month" => 12, "Day" => 31, "Hour" => 23, "Minute" => 59 },
  "MaximumStaticDraught"   => 7.4,
  "Destination"            => "LE HAVRE",
  "DTE"                    => false
})
# Two NMEA sentences are printed (multi-part message)
```

---

## 04 — Safety Broadcast Message (Type 14)

```ruby
require 'ais_to_nmea'

puts AisToNmea.to_nmea({
  "MessageID" => 14,
  "UserID"    => 123456789,
  "Text"      => "SECURITE NAVIGATION"
})
```

---

## 04b — Base Station Report (Type 4)

```ruby
require 'ais_to_nmea'

puts AisToNmea.to_nmea({
  "MessageID"          => 4,
  "RepeatIndicator"    => 0,
  "UserID"             => 123456789,
  "UtcYear"            => 2026,
  "UtcMonth"           => 3,
  "UtcDay"             => 29,
  "UtcHour"            => 12,
  "UtcMinute"          => 34,
  "UtcSecond"          => 56,
  "PositionAccuracy"   => true,
  "Longitude"          => 2.3522,
  "Latitude"           => 48.8566,
  "FixType"            => 1,
  "LongRangeEnable"    => false,
  "Spare"              => 0,
  "Raim"               => false,
  "CommunicationState" => 0
})
```

---

## 05 — Error Handling

```ruby
require 'ais_to_nmea'

# Missing required field
begin
  AisToNmea.to_nmea({ "MessageID" => 1, "UserID" => 123456789 })
rescue AisToNmea::MissingFieldError => e
  puts e.message   # => Missing required field: Latitude
end

# Out-of-range value
begin
  AisToNmea.to_nmea({
    "MessageID" => 1, "UserID" => 123456789,
    "Latitude"  => 95.0,           # invalid
    "Longitude" => 2.3522, "SpeedOverGround" => 12.3,
    "CourseOverGround" => 254.8, "TrueHeading" => 255
  })
rescue AisToNmea::InvalidFieldError => e
  puts e.message
end
```

---

## 06 — Direct Encoder Usage (Batch Processing)

```ruby
require 'ais_to_nmea'

encoder = AisToNmea::Encoder.new

messages = [
  { "MessageID" => 1, "UserID" => 111111111, "Latitude" => 48.8566,
    "Longitude" => 2.3522, "SpeedOverGround" => 5.0,
    "CourseOverGround" => 90.0, "TrueHeading" => 90 },
  { "MessageID" => 1, "UserID" => 222222222, "Latitude" => 51.5074,
    "Longitude" => -0.1278, "SpeedOverGround" => 8.5,
    "CourseOverGround" => 123.4, "TrueHeading" => 120 }
]

messages.each { |m| puts encoder.encode(m) }
```

---

[← Error Handling](error-handling) | [Home →](index)
