# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::PositionReport::Sog do
  it 'normalizes the input value' do
    expect(described_class.new("12.3").value).to eq(12.3)
  end

  it 'accepts a valid value' do
    part = described_class.new(12.3)
    expect(part.validate!).to eq(part)
  end

  describe '#pack' do
    subject { described_class.new(12.3) }

    it 'packs value into AIS bits' do
      expect(subject.pack.length).to eq(10)
    end
  end
end
