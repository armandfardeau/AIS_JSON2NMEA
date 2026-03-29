# AIS JSON to NMEA Ruby Gem

Convert AIS (Automatic Identification System) JSON messages into raw NMEA 0183 AIS sentences using a pure Ruby encoder.

📖 **[Full Documentation](https://armandfardeau.github.io/AIS_JSON2NMEA/)**

## Features

- **Supported AIS Message Types**: 1, 2, 3 (Position Reports), 5 (Ship Static Data), 14 (Safety Broadcast Message)
- **Multiple Input Formats**: Ruby Hash or JSON string
- **Valid NMEA Output**: 6-bit encoding, correct fill bits, valid checksums
- **Multi-part Support**: Automatically splits long messages into multiple NMEA sentences
- **Production Ready**: Comprehensive error handling and validation
- **Pure Ruby**: No native extension, no external C++ dependencies

## Requirements

### System Dependencies

- **Ruby 3.2+**
- **RubyGems**

No external AIS/C++ library is required.

## Installation

Add to your `Gemfile`:

```ruby
gem 'ais_to_nmea'
```

Then install:

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

# Simple hash input
position_report = {
  "MessageID" => 1,
  "UserID" => 123456789,
  "Latitude" => 48.8566,
  "Longitude" => 2.3522,
  "SpeedOverGround" => 12.3,
  "CourseOverGround" => 254.8,
  "TrueHeading" => 255
}

# Convert to NMEA
nmea = AisToNmea.to_nmea(position_report)
puts nmea
# => !AIVDM,1,1,,A,15M67...*XX

# Or use JSON string
json_input = '{"MessageID":1,"UserID":123456789,...}'
nmea = AisToNmea.to_nmea(json_input)
```

## API

### `AisToNmea.to_nmea(input, options = {})`

Convenience method for converting AIS JSON to NMEA.

**Parameters:**
- `input` (String or Hash): JSON string or Ruby Hash containing AIS message
- `options` (Hash): Additional options (reserved for future use)

**Returns:** String containing NMEA sentence(s), joined with `\n` for multi-part

**Raises:**
- `AisToNmea::InvalidJsonError` - Malformed JSON
- `AisToNmea::MissingFieldError` - Required field missing
- `AisToNmea::InvalidFieldError` - Field value out of valid range
- `AisToNmea::UnsupportedMessageTypeError` - Message type not supported
- `AisToNmea::EncodingError` - AIS encoding failed
- `AisToNmea::MemoryError` - Memory allocation failure

### `AisToNmea::Encoder.new.encode(input, options = {})`

Direct encoder class for more control.

```ruby
encoder = AisToNmea::Encoder.new
nmea = encoder.encode(input_hash)
```

## Input Format

### AIS Position Report (Message Types 1, 2, 3)

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

Or with nested structure:

```json
{
  "MessageType": "PositionReport",
  "Message": {
    "MessageID": 1,
    "UserID": 123456789,
    ...
  }
}
```

### AIS Safety Broadcast Message (Message Type 14)

```json
{
  "MessageID": 14,
  "RepeatIndicator": 0,
  "UserID": 123456789,
  "Valid": true,
  "Spare": 0,
  "Text": "SECURITE NAVIGATION"
}
```

Field notes for message type 14:

- `MessageID`: must be `14`
- `RepeatIndicator`: optional, integer `0..3`, default `0`
- `UserID`: required MMSI (mapped to the AIS source identifier)
- `Valid`: accepted for compatibility, not encoded in type 14 payload
- `Spare`: optional, integer `0..3`, default `0`
- `Text`: required AIS text payload, max length `156` characters

### Field Descriptions

| Field | Type | Valid Range | Required | Notes |
|-------|------|-------------|----------|-------|
| MessageID | Integer | 1-3 | Yes | AIS message type |
| UserID | Integer | 0-9999999999 | Yes | MMSI (Maritime Mobile Service Identity) |
| Latitude | Float | -90.0 to 90.0 | Yes | Degrees, decimal |
| Longitude | Float | -180.0 to 180.0 | Yes | Degrees, decimal |
| SpeedOverGround | Float | 0.0 to 200.0 | Yes | Knots (values above 102.2 are encoded as 102.3/unavailable) |
| CourseOverGround | Float | 0.0 to 359.9 | Yes | Degrees |
| TrueHeading | Integer | 0-359 | Yes | Degrees (511 = not available) |
| NavigationStatus | Integer | 0-15 | No | Default: 0 (Under way using engine) |

### Navigation Status Codes

- `0` - Under way using engine
- `1` - At anchor
- `2` - Not under command
- `3` - Restricted maneuverability
- `4` - Constrained by draft
- `5` - Moored
- `6` - Aground
- `7` - Engaged in fishing
- `8` - Under way sailing
- `9-14` - Reserved for future use
- `15` - Not defined

## Output Format

NMEA 0183 AIS sentences in the format:

```
!AIVDM,<total>,<sequence>,<id>,<channel>,<payload>,<fill>,<checksum>
```

### Example Output

Single-sentence message:
```
!AIVDM,1,1,,A,15M67FC000G?ufbE`FepT@3n00Sa,0*5C
```

Multi-sentence message:
```
!AIVDM,2,1,3,B,55?MbV02>H97ac<H88888888888888888800000000000000000,0*39
!AIVDM,2,2,3,B,00000000000,2*22
```

### NMEA Fields

- `1` - Sentence type (`AIVDM` = received, `AIVDO` = not heard)
- `2` - Total number of sentences (1-9)
- `3` - Sentence sequence number (1-based)
- `4` - Sequential message ID (0-9)
- `5` - AIS channel (A or B)
- `6` - Encoded 6-bit payload
- `7` - Fill bits (0-5)
- `8` - Checksum (XOR of all chars between `!` and `*`, hex)

## Error Handling

```ruby
require 'ais_to_nmea'

input = {
  "MessageID" => 1,
  "UserID" => 123456789,
  # Missing Latitude!
  "Longitude" => 2.3522,
  "SpeedOverGround" => 12.3,
  "CourseOverGround" => 254.8,
  "TrueHeading" => 255
}

begin
  nmea = AisToNmea.to_nmea(input)
rescue AisToNmea::MissingFieldError => e
  puts "Missing field: #{e.message}"
  # => Missing field: Missing required field: Latitude
rescue AisToNmea::InvalidFieldError => e
  puts "Invalid value: #{e.message}"
rescue AisToNmea::UnsupportedMessageTypeError => e
  puts "Message type not supported: #{e.message}"
rescue AisToNmea::Error => e
  puts "AIS encoding error: #{e.message}"
end
```

## Examples

Examples are split by use case in the [examples](examples) directory:

- [examples/01_position_reports.rb](examples/01_position_reports.rb) - Message types 1, 2, 3
- [examples/02_input_formats.rb](examples/02_input_formats.rb) - Hash and JSON string inputs (with explicit encoder for JSON)
- [examples/03_ship_static_data.rb](examples/03_ship_static_data.rb) - Message type 5
- [examples/04_safety_broadcast_message.rb](examples/04_safety_broadcast_message.rb) - Message type 14
- [examples/05_error_handling.rb](examples/05_error_handling.rb) - Missing field and invalid value cases
- [examples/06_direct_encoder_usage.rb](examples/06_direct_encoder_usage.rb) - Direct `AisToNmea::Encoder` usage

Run one example:

```bash
bundle exec ruby -Ilib examples/01_position_reports.rb
```

Run all examples:

```bash
for f in examples/[0-9][0-9]_*.rb; do bundle exec ruby -Ilib "$f"; done
```

## Testing

Run the test suite:

```bash
bundle exec rake spec
```

Or with RSpec directly:

```bash
bundle exec rspec spec/
```

### Test Coverage

The gem includes tests for:

- Message types 1, 2, 3, 5 and 14
- Hash and JSON string inputs
- Valid NMEA format generation
- Checksum calculation and validation
- Multi-part message handling
- Error cases (missing fields, out-of-range values)
- Input validation

## Linting

This project uses [RuboCop](https://rubocop.org/) and [rubocop-rspec](https://github.com/rubocop/rubocop-rspec) for code style enforcement.

Run the linter:

```bash
bundle exec rake lint
```

Auto-fix all correctable offenses:

```bash
bundle exec rake lint:fix
```

Linting is also enforced automatically on every push and pull request via GitHub Actions.

## Building from Source

### Prerequisites

- Ruby 3.2+
- Bundler

### Build Steps

```bash
# Clone and enter directory
git clone https://github.com/armandfardeau/AIS_JSON2NMEA.git
cd AIS_JSON2NMEA

# Install dependencies
bundle install

# Run tests
bundle exec rake spec

# Build gem
bundle exec rake build
```

### Troubleshooting

#### Installation issues

Verify Ruby and Bundler:

```bash
ruby --version
bundle --version
```

If dependencies were added/changed:

```bash
bundle install
```

## Architecture

```
lib/ais_to_nmea.rb          # Ruby API and encoder
├── lib/ais_to_nmea/
│   ├── version.rb           # Version constant
│   ├── errors.rb            # Exception classes
│   └── message_type.rb      # JSON parsing & type detection
```

### Component Descriptions

- **Ruby Layer** (`lib/ais_to_nmea.rb`): AIS bit packing, 6-bit armoring, NMEA formatting
- **Message Parsing** (`lib/ais_to_nmea/message_type.rb`): JSON parsing and message type detection

## Supported Platforms

- **Linux** (x86_64, ARM, etc.)
- **macOS** (Intel, Apple Silicon)
- Windows support coming in future release

## Performance

Typical encoding time: **< 1ms** per message

For batch processing:

```ruby
encoder = AisToNmea::Encoder.new
messages = [msg1, msg2, msg3, ...]

results = messages.map { |msg| encoder.encode(msg) }
```

## Limitations

### Current Release

- **Message types**: 1, 2, 3, 5 and 14 are supported
- **No decoding**: NMEA → AIS parsing not implemented (output only)
- **Platform**: Any platform running Ruby 3.2+

### Future Enhancements

- Support for additional message types (4, 5, 18, 24, etc.)
- NMEA sentence parsing and validation
- Windows support
- Performance optimizations
- Multi-threading support

## Contributing

Issues and pull requests welcome on GitHub: https://github.com/armandfardeau/AIS_JSON2NMEA

## License

MIT License - see LICENSE file for details

## References

### AIS Standards

- [AIVDM/AIVDO Protocol Decoding](https://gpsd.gitlab.io/gpsd/AIVDM.html)
- [IEC 61162-1 (NMEA 0183)](https://www.iec.ch/)
- [ITU-R M.1371-5 (AIS Specification)](https://www.itu.int/)

### Libraries

- [Ruby JSON Documentation](https://ruby-doc.org/3.2.0/exts/json/JSON.html)

## Acknowledgments

- Built as a pure Ruby AIS encoder