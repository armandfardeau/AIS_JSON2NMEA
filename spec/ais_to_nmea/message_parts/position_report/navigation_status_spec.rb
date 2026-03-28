# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::PositionReport::NavigationStatus do
  it 'normalizes the input value' do
    expect(described_class.new('3').value).to eq(3)
  end

  it 'accepts a valid value' do
    part = described_class.new(3)
    expect(part.validate!).to eq(part)
  end

  describe '#pack' do
    subject { described_class.new(3) }

    it 'packs value into AIS bits' do
      expect(subject.pack).to eq('0011')
    end
  end
end
