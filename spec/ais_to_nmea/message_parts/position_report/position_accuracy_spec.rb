# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::PositionReport::PositionAccuracy do
  it 'normalizes the input value' do
    expect(described_class.new("1").value).to eq(1)
  end

  it 'accepts a valid value' do
    part = described_class.new(1)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(2).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  describe '#pack' do
    subject { described_class.new(1) }

    it 'packs value into AIS bits' do
      expect(subject.pack).to eq('1')
    end
  end
end
