# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::PositionReport::Raim do
  it 'normalizes the input value' do
    expect(described_class.new('0').value).to eq(0)
  end

  it 'normalizes boolean inputs', :aggregate_failures do
    expect(described_class.new(true).value).to eq(1)
    expect(described_class.new(false).value).to eq(0)
  end

  it 'accepts a valid value' do
    part = described_class.new(0)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(2).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  describe '#pack' do
    subject(:message_part) { described_class.new(1) }

    it 'packs value into AIS bits' do
      expect(message_part.pack).to eq('1')
    end
  end
end
