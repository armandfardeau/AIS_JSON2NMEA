# frozen_string_literal: true

require 'spec_helper'

describe AisToNmea::Validation do
  describe '.validate_ranges!' do
    it 'accepts valid boundary values' do
      expect do
        described_class.validate_ranges!(lat: -90.0, lon: 180.0, sog: 102.2, cog: 359.9, heading: 511, nav_status: 15)
      end.not_to raise_error
    end

    it 'rejects latitude out of range' do
      expect do
        described_class.validate_ranges!(lat: 90.1, lon: 0.0, sog: 0.0, cog: 0.0, heading: 0, nav_status: 0)
      end.to raise_error(AisToNmea::InvalidFieldError, /Latitude must be between -90 and 90/)
    end

    it 'rejects longitude out of range' do
      expect do
        described_class.validate_ranges!(lat: 0.0, lon: -180.1, sog: 0.0, cog: 0.0, heading: 0, nav_status: 0)
      end.to raise_error(AisToNmea::InvalidFieldError, /Longitude must be between -180 and 180/)
    end

    it 'rejects sog out of range' do
      expect do
        described_class.validate_ranges!(lat: 0.0, lon: 0.0, sog: 102.3, cog: 0.0, heading: 0, nav_status: 0)
      end.to raise_error(AisToNmea::InvalidFieldError, %r{Sog/SpeedOverGround})
    end

    it 'rejects cog out of range' do
      expect do
        described_class.validate_ranges!(lat: 0.0, lon: 0.0, sog: 0.0, cog: 360.0, heading: 0, nav_status: 0)
      end.to raise_error(AisToNmea::InvalidFieldError, %r{Cog/CourseOverGround})
    end

    it 'rejects invalid heading other than 511 sentinel' do
      expect do
        described_class.validate_ranges!(lat: 0.0, lon: 0.0, sog: 0.0, cog: 0.0, heading: 360, nav_status: 0)
      end.to raise_error(AisToNmea::InvalidFieldError, /TrueHeading/)
    end

    it 'rejects navigation status out of range' do
      expect do
        described_class.validate_ranges!(lat: 0.0, lon: 0.0, sog: 0.0, cog: 0.0, heading: 0, nav_status: 16)
      end.to raise_error(AisToNmea::InvalidFieldError, /NavigationStatus/)
    end
  end
end
