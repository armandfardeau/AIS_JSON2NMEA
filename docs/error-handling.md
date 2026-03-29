---
title: Error Handling
---

# Error Handling

All exceptions inherit from `AisToNmea::Error`, so you can rescue them specifically or as a group.

## Exception Hierarchy

```
AisToNmea::Error
├── AisToNmea::InvalidJsonError
├── AisToNmea::MissingFieldError
├── AisToNmea::InvalidFieldError
├── AisToNmea::UnsupportedMessageTypeError
└── AisToNmea::EncodingError
    └── AisToNmea::EncodingFailureError
```

## Exception Reference

| Class | Raised when |
|-------|-------------|
| `InvalidJsonError` | Input string is not valid JSON |
| `MissingFieldError` | A required field is absent from the input |
| `InvalidFieldError` | A field value is outside its valid range |
| `UnsupportedMessageTypeError` | `MessageID` is not one of 1, 2, 3, 5, 14 |
| `EncodingError` | Failure during AIS bit-packing or 6-bit armoring |
| `EncodingFailureError` | Unexpected internal error during encoding (subclass of `EncodingError`) |

## Example

```ruby
require 'ais_to_nmea'

input = {
  "MessageID"        => 1,
  "UserID"           => 123456789,
  # Missing Latitude
  "Longitude"        => 2.3522,
  "SpeedOverGround"  => 12.3,
  "CourseOverGround" => 254.8,
  "TrueHeading"      => 255
}

begin
  AisToNmea.to_nmea(input)
rescue AisToNmea::MissingFieldError => e
  puts e.message
  # => Missing required field: Latitude
rescue AisToNmea::InvalidFieldError => e
  puts "Invalid value: #{e.message}"
rescue AisToNmea::UnsupportedMessageTypeError => e
  puts "Unsupported type: #{e.message}"
rescue AisToNmea::Error => e
  puts "AIS error: #{e.message}"
end
```

## Catching All AIS Errors

```ruby
begin
  AisToNmea.to_nmea(input)
rescue AisToNmea::Error => e
  puts "#{e.class}: #{e.message}"
end
```

---

[← Input Formats](input-formats) | [Examples →](examples)
