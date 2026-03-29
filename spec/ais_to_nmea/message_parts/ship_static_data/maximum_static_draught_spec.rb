# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::ShipStaticData::MaximumStaticDraught do
  it 'normalizes the input value' do
    expect(described_class.new('7.4').value).to eq(7.4)
  end

  it 'accepts a valid value' do
    part = described_class.new(nil)
    expect(part.validate!).to eq(part)
  end

  it 'normalizes nil to default draught value' do
    part = described_class.new(nil)
    part.validate!
    expect(part.value).to eq(0.0)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(26.0).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  describe '#pack' do
    subject(:message_part) { described_class.new(7.4) }

    it 'packs value into AIS bits' do
      expect(message_part.pack.length).to eq(8)
    end
  end
end
