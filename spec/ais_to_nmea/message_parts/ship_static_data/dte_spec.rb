# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::ShipStaticData::Dte do
  it 'normalizes the input value' do
    expect(described_class.new(true).value).to eq(1)
  end

  it 'accepts a valid value' do
    part = described_class.new(true)
    expect(part.validate!).to eq(part)
  end

  describe '#pack' do
    subject(:message_part) { described_class.new(true) }

    it 'packs value into AIS bits' do
      expect(message_part.pack).to eq('1')
    end
  end
end
