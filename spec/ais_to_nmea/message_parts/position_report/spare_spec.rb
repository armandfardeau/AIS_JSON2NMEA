# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::PositionReport::Spare do
  it 'normalizes the input value' do
    expect(described_class.new("7").value).to eq(7)
  end

  it 'accepts a valid value' do
    part = described_class.new(7)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(8).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  describe '#pack' do
    subject { described_class.new(7) }

    it 'packs value into AIS bits' do
      expect(subject.pack).to eq('111')
    end
  end
end
