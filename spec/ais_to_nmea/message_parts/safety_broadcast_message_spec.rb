# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::SafetyBroadcastMessage do
  it 'is defined' do
    expect(described_class).not_to be_nil
  end

  it 'is a module' do
    expect(described_class).to be_a(Module)
  end

  describe 'safety broadcast field classes' do
    it 'defines all expected field classes' do
      expect(described_class.constants).to include(
        :RepeatIndicator,
        :Spare,
        :Text
      )
    end

    it 'has field classes that inherit from MessageParts::Base' do
      %i[RepeatIndicator Spare Text].each do |field_class|
        expect(described_class.const_get(field_class)).to be < AisToNmea::MessageParts::Base
      end
    end
  end
end
