# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::ShipStaticData::Dimensions::D do
  it 'normalizes the input value' do
    expect(described_class.new('60').value).to eq(60)
  end

  it 'accepts a valid value' do
    part = described_class.new(60)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(64).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  describe '#pack' do
    subject { described_class.new(60) }

    it 'packs value into AIS bits' do
      expect(subject.pack.length).to eq(6)
    end
  end
end
