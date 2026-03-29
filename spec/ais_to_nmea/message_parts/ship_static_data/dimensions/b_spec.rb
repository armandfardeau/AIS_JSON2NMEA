# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::ShipStaticData::Dimensions::B do
  it 'normalizes the input value' do
    expect(described_class.new('200').value).to eq(200)
  end

  it 'accepts a valid value' do
    part = described_class.new(200)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(512).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  describe '#pack' do
    subject(:message_part) { described_class.new(200) }

    it 'packs value into AIS bits' do
      expect(message_part.pack.length).to eq(9)
    end
  end
end
