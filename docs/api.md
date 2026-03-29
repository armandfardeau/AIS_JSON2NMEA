---
title: API Reference
---

# API Reference

## `AisToNmea.to_nmea(data, encoder: nil)`

Top-level convenience method for converting AIS JSON to NMEA.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `String` or `Hash` | JSON string or Ruby Hash containing an AIS message |
| `encoder` | `Symbol` or `nil` | Encoder key (e.g. `:position_report`); skips `MessageID` auto-detection when set |

**Returns:** `String` — one or more NMEA sentences joined with `\n` for multi-part messages.

**Raises**

| Exception | Cause |
|-----------|-------|
| `AisToNmea::InvalidJsonError` | Malformed JSON string |
| `AisToNmea::MissingFieldError` | A required field is absent |
| `AisToNmea::InvalidFieldError` | A field value is out of valid range |
| `AisToNmea::UnsupportedMessageTypeError` | `MessageID` is not supported |
| `AisToNmea::EncodingError` | Failure during AIS bit-packing or 6-bit armoring |
| `AisToNmea::EncodingFailureError` | Unexpected internal error; subclass of `EncodingError` |

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

Direct encoder class for encoding a single message.

### `Encoder.new(data:)`

Creates a new encoder for the given message. `data` accepts the same String or Hash as `AisToNmea.to_nmea`.

### `#encode`

Encodes the message provided at construction. Returns the same String as `AisToNmea.to_nmea`.

**Example**

```ruby
# Single message
result = AisToNmea::Encoder.new(data: message).encode

# Batch — one Encoder per message
results = messages.map { |msg| AisToNmea::Encoder.new(data: msg).encode }

# Batch — bypass MessageID auto-detection for known types
results = messages.map { |msg| AisToNmea.to_nmea(msg, encoder: :position_report) }
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
