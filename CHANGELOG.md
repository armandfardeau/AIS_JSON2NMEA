# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Removed

- **`MemoryError`** — Removed the `AisToNmea::MemoryError` exception class. It was defined but never raised anywhere in the codebase, making it dead code with no runtime contract. Removed the class definition and all references in specs and documentation.

- **`options` parameter** — Removed the `options:` keyword argument from `AisToNmea.to_nmea`, `AisToNmea::Encoder.new`, `AisToNmea::EncoderFactory.build`, and `AisToNmea::Encoders::Base.new`. The parameter was passed through the entire call chain but never consumed by any encoder, providing no runtime behaviour. Removed from all method signatures, documentation, and specs.

- **`Common::Valid` message part** — Removed the `AisToNmea::MessageParts::Common::Valid` class and its YAML mapping entry. The class was defined and listed in the shared `common` section of `mapping.yml`, but its anchor (`*common_valid`) was never referenced in any active encoder mapping (`position_report`, `ship_static_data`, `safety_broadcast_message`). The `Valid` field is not a standard bit field in AIS message types 1/2/3/5/14, so the part was never packed into any output. Removed the class, its mapping entry, and its spec.
