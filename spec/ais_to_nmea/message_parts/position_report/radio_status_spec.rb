# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::PositionReport::RadioStatus do
  it 'normalizes the input value' do
    expect(described_class.new('128').value).to eq(128)
  end

  it 'accepts a valid value' do
    part = described_class.new(128)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(524_288).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  describe '#pack' do
    subject(:message_part) { described_class.new(128) }

    it 'packs value into AIS bits' do
      expect(message_part.pack.length).to eq(19)
    end
  end
end
