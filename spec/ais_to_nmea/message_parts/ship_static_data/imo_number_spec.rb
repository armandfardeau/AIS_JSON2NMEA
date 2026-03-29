# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::ShipStaticData::ImoNumber do
  it 'normalizes the input value' do
    expect(described_class.new('1234567').value).to eq(1_234_567)
  end

  it 'accepts a valid value' do
    part = described_class.new(1_234_567)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(-1).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  describe '#pack' do
    subject(:message_part) { described_class.new(1_234_567) }

    it 'packs value into AIS bits' do
      expect(message_part.pack.length).to eq(30)
    end
  end
end
