# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::ShipStaticData::Etas::Day do
  it 'normalizes the input value' do
    expect(described_class.new('31').value).to eq(31)
  end

  it 'accepts a valid value' do
    part = described_class.new(31)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(32).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  describe '#pack' do
    subject { described_class.new(31) }

    it 'packs value into AIS bits' do
      expect(subject.pack).to eq('11111')
    end
  end
end
