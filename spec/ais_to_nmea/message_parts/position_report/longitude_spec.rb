# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::PositionReport::Longitude do
  it 'normalizes the input value' do
    expect(described_class.new('2.3522').value).to eq(2.3522)
  end

  it 'accepts a valid value' do
    part = described_class.new(2.3522)
    expect(part.validate!).to eq(part)
  end

  describe '#pack' do
    subject { described_class.new(2.3522) }

    it 'packs value into AIS bits' do
      expect(subject.pack.length).to eq(28)
    end
  end
end
