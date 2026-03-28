# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::PositionReport::Rot do
  it 'normalizes the input value' do
    expect(described_class.new("-10").value).to eq(-10)
  end

  it 'accepts a valid value' do
    part = described_class.new(-10)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(-129).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  describe '#pack' do
    subject { described_class.new(-10) }

    it 'packs value into AIS bits' do
      expect(subject.pack).to eq('11110110')
    end
  end
end
