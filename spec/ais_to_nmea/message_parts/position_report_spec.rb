# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::PositionReport do
  it 'is defined' do
    expect(described_class).not_to be_nil
  end

  it 'is a module' do
    expect(described_class).to be_a(Module)
  end

  describe 'position report field classes' do
    let(:expected_fields) do
      %i[
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
    end

    it 'defines all expected field classes' do
      expect(described_class.constants).to match_array(expected_fields)
    end

    it 'has field classes that inherit from MessageParts::Base' do
      expected_fields.each do |field_class|
        expect(described_class.const_get(field_class)).to be < AisToNmea::MessageParts::Base
      end
    end
  end
end
