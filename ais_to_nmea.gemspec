require_relative "lib/ais_to_nmea/version"

Gem::Specification.new do |spec|
  spec.name          = "ais_to_nmea"
  spec.version       = AisToNmea::VERSION
  spec.authors       = ["AIS Developer"]
  spec.email         = ["dev@example.com"]

  spec.summary       = "Convert AIS JSON messages to NMEA 0183 sentences"
  spec.description   = "A Ruby gem that converts AIS Position Report JSON (types 1, 2, 3) into raw NMEA 0183 AIS sentences using a pure Ruby encoder"
  spec.homepage      = "https://github.com/armandfardeau/AIS_JSON2NMEA"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.files = Dir.glob("lib/**/*") +
               %w[README.md Gemfile ais_to_nmea.gemspec]

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rake-compiler", "~> 1.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "https://github.com/armandfardeau/AIS_JSON2NMEA/issues"
  spec.metadata["changelog_uri"] = "https://github.com/armandfardeau/AIS_JSON2NMEA/blob/main/CHANGELOG.md"

  spec.post_install_message = <<~MSG
    ========================================
    AIS to NMEA Gem Installation
    ========================================

    Pure Ruby mode enabled: no native compilation required.

    For usage examples, see README.md.
    ========================================
  MSG
end
