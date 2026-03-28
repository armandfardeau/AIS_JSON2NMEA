# frozen_string_literal: true

require 'spec_helper'

describe AisToNmea::AisEncoder::Utils::Validation do
  describe '.validate_ranges!' do
    it 'accepts valid boundary values' do
      expect do
        described_class.validate_ranges!(-90.0, 180.0, 102.2, 359.9, 511, 15)
      end.not_to raise_error
    end

    it 'rejects latitude out of range' do
      expect do
        described_class.validate_ranges!(90.1, 0.0, 0.0, 0.0, 0, 0)
      end.to raise_error(AisToNmea::InvalidFieldError, /Latitude must be between -90 and 90/)
    end

    it 'rejects longitude out of range' do
      expect do
        described_class.validate_ranges!(0.0, -180.1, 0.0, 0.0, 0, 0)
      end.to raise_error(AisToNmea::InvalidFieldError, /Longitude must be between -180 and 180/)
    end

    it 'rejects sog out of range' do
      expect do
        described_class.validate_ranges!(0.0, 0.0, 102.3, 0.0, 0, 0)
      end.to raise_error(AisToNmea::InvalidFieldError, %r{Sog/SpeedOverGround})
    end

    it 'rejects cog out of range' do
      expect do
        described_class.validate_ranges!(0.0, 0.0, 0.0, 360.0, 0, 0)
      end.to raise_error(AisToNmea::InvalidFieldError, %r{Cog/CourseOverGround})
    end

    it 'rejects invalid heading other than 511 sentinel' do
      expect do
        described_class.validate_ranges!(0.0, 0.0, 0.0, 0.0, 360, 0)
      end.to raise_error(AisToNmea::InvalidFieldError, /TrueHeading/)
    end

    it 'rejects navigation status out of range' do
      expect do
        described_class.validate_ranges!(0.0, 0.0, 0.0, 0.0, 0, 16)
      end.to raise_error(AisToNmea::InvalidFieldError, /NavigationStatus/)
    end
  end
end
