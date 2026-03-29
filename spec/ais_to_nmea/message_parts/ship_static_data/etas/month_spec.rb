# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::ShipStaticData::Etas::Month do
  it 'normalizes the input value' do
    expect(described_class.new('12').value).to eq(12)
  end

  it 'accepts a valid value' do
    part = described_class.new(12)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(13).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  describe '#pack' do
    subject(:message_part) { described_class.new(12) }

    it 'packs value into AIS bits' do
      expect(message_part.pack).to eq('1100')
    end
  end
end
