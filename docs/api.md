---
title: API Reference
---

# API Reference

## `AisToNmea.to_nmea(input, options = {})`

Top-level convenience method for converting AIS JSON to NMEA.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | `String` or `Hash` | JSON string or Ruby Hash containing an AIS message |
| `options` | `Hash` | Reserved for future use |

**Returns:** `String` — one or more NMEA sentences joined with `\n` for multi-part messages.

**Raises**

| Exception | Cause |
|-----------|-------|
| `AisToNmea::InvalidJsonError` | Malformed JSON string |
| `AisToNmea::MissingFieldError` | A required field is absent |
| `AisToNmea::InvalidFieldError` | A field value is out of valid range |
| `AisToNmea::UnsupportedMessageTypeError` | `MessageID` is not supported |
| `AisToNmea::EncodingError` | Failure during AIS bit-packing or 6-bit armoring |

**Example**

```ruby
nmea = AisToNmea.to_nmea({
  "MessageID"        => 1,
  "UserID"           => 123456789,
  "Latitude"         => 48.8566,
  "Longitude"        => 2.3522,
  "SpeedOverGround"  => 12.3,
  "CourseOverGround" => 254.8,
  "TrueHeading"      => 255
})
```

---

## `AisToNmea::Encoder`

Direct encoder class for reuse across multiple messages.

### `Encoder.new`

Creates a new encoder instance. Prefer this for batch processing — instantiation cost is paid once.

### `#encode(input, options = {})`

Same signature and return value as `AisToNmea.to_nmea`.

**Example**

```ruby
encoder = AisToNmea::Encoder.new

results = messages.map { |msg| encoder.encode(msg) }
```

---

## NMEA Output Format

Each sentence follows the NMEA 0183 AIS format:

```
!AIVDM,<total>,<seq>,<id>,<channel>,<payload>,<fill>*<checksum>
```

| Field | Description |
|-------|-------------|
| `total` | Total number of sentences for this message |
| `seq` | Sentence sequence number (1-based) |
| `id` | Sequential message ID (0–9), present only for multi-part |
| `channel` | AIS channel (`A` or `B`) |
| `payload` | 6-bit armored payload |
| `fill` | Fill bits (0–5) |
| `checksum` | XOR of all characters between `!` and `*`, hex |

**Single-sentence example**

```
!AIVDM,1,1,,A,15M67FC000G?ufbE`FepT@3n00Sa,0*5C
```

**Multi-sentence example (message type 5)**

```
!AIVDM,2,1,3,B,55?MbV02>H97ac<H88888888888888888800000000000000000,0*39
!AIVDM,2,2,3,B,00000000000,2*22
```

---

[← Getting Started](getting-started) | [Input Formats →](input-formats)
