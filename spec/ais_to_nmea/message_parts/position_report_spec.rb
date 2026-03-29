# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/ExampleLength

RSpec.describe AisToNmea::MessageParts::PositionReport do
  it 'is defined' do
    expect(described_class).not_to be_nil
  end

  it 'is a module' do
    expect(described_class).to be_a(Module)
  end

  describe 'position report field classes' do
    it 'defines all expected field classes' do
      expect(described_class.constants).to include(
        :RepeatIndicator,
        :NavigationStatus,
        :Rot,
        :Sog,
        :PositionAccuracy,
        :Longitude,
        :Latitude,
        :Cog,
        :Heading,
        :Timestamp,
        :Maneuver,
        :Spare,
        :Raim,
        :RadioStatus
      )
    end

    it 'has field classes that inherit from MessageParts::Base' do
      expected_fields = %i[
        RepeatIndicator
        NavigationStatus
        Rot
        Sog
        PositionAccuracy
        Longitude
        Latitude
        Cog
        Heading
        Timestamp
        Maneuver
        Spare
        Raim
        RadioStatus
      ]

      expected_fields.each do |field_class|
        expect(described_class.const_get(field_class)).to be < AisToNmea::MessageParts::Base
      end
    end
  end
end
# rubocop:enable RSpec/ExampleLength
