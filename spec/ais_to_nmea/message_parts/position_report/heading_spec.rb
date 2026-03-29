# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::PositionReport::Heading do
  it 'normalizes the input value' do
    expect(described_class.new('255').value).to eq(255)
  end

  it 'accepts a valid value' do
    part = described_class.new(255)
    expect(part.validate!).to eq(part)
  end

  describe '#pack' do
    subject(:message_part) { described_class.new(255) }

    it 'packs value into AIS bits' do
      expect(message_part.pack.length).to eq(9)
    end
  end
end
