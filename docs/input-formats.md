---
title: Input Formats
---

# Input Formats

All inputs can be provided as a **Ruby Hash** or a **JSON string**.

---

## Position Report — Message Types 1, 2, 3

### Required Fields

| Field | Type | Valid Range | Notes |
|-------|------|-------------|-------|
| `MessageID` | Integer | 1, 2, or 3 | AIS message type |
| `UserID` | Integer | 0–9 999 999 999 | MMSI |
| `Latitude` | Float | -90.0 to 90.0 | Decimal degrees |
| `Longitude` | Float | -180.0 to 180.0 | Decimal degrees |
| `SpeedOverGround` | Float | 0.0 to 102.2 | Knots |
| `CourseOverGround` | Float | 0.0 to 359.9 | Degrees |
| `TrueHeading` | Integer | 0–359 (or 511) | 511 = not available |

### Optional Fields

| Field | Type | Valid Range | Default |
|-------|------|-------------|---------|
| `NavigationStatus` | Integer | 0–15 | 0 |
| `RepeatIndicator` | Integer | 0–3 | 0 |
| `RateOfTurn` | Integer | -128 to 127 | 0 |
| `PositionAccuracy` | Integer | 0–1 | 0 |
| `Timestamp` | Integer | 0–63 | 0 |

### Navigation Status Codes

| Code | Meaning |
|------|---------|
| 0 | Under way using engine |
| 1 | At anchor |
| 2 | Not under command |
| 3 | Restricted maneuverability |
| 4 | Constrained by draft |
| 5 | Moored |
| 6 | Aground |
| 7 | Engaged in fishing |
| 8 | Under way sailing |
| 9–14 | Reserved |
| 15 | Not defined |

### Example

```json
{
  "MessageID": 1,
  "UserID": 123456789,
  "Latitude": 48.8566,
  "Longitude": 2.3522,
  "SpeedOverGround": 12.3,
  "CourseOverGround": 254.8,
  "TrueHeading": 255,
  "NavigationStatus": 0
}
```

---

## Ship Static Data — Message Type 5

Multi-part message (always produces two NMEA sentences).

```json
{
  "MessageID": 5,
  "UserID": 636024245,
  "IMONumber": 9876543,
  "CallSign": "FRA1234",
  "Name": "TEST VESSEL",
  "ShipType": 70,
  "Dimension": { "A": 50, "B": 20, "C": 5, "D": 5 },
  "FixType": 1,
  "Eta": { "Month": 12, "Day": 31, "Hour": 23, "Minute": 59 },
  "MaximumStaticDraught": 7.4,
  "Destination": "LE HAVRE",
  "DTE": false
}
```

---

## Safety Broadcast Message — Message Type 14

| Field | Type | Valid Range | Notes |
|-------|------|-------------|-------|
| `MessageID` | Integer | 14 | Required |
| `UserID` | Integer | 0–9 999 999 999 | MMSI |
| `Text` | String | max 156 chars | AIS 6-bit text |
| `RepeatIndicator` | Integer | 0–3 | Optional, default 0 |

```json
{
  "MessageID": 14,
  "UserID": 123456789,
  "Text": "SECURITE NAVIGATION"
}
```

---

## Nested Format

Inputs can also use a nested `Message` wrapper:

```json
{
  "MessageType": "PositionReport",
  "Message": {
    "MessageID": 1,
    "UserID": 123456789,
    "Latitude": 48.8566,
    "Longitude": 2.3522,
    "SpeedOverGround": 12.3,
    "CourseOverGround": 254.8,
    "TrueHeading": 255
  }
}
```

---

[← API Reference](api) | [Error Handling →](error-handling)
