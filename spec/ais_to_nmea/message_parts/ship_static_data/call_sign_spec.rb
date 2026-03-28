# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::ShipStaticData::CallSign do
  it 'normalizes the input value' do
    expect(described_class.new(123).value).to eq('123')
  end

  it 'accepts a valid value' do
    part = described_class.new('ABC123')
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new('TOO-LONG-8').validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  describe '#pack' do
    subject { described_class.new('ABC123') }

    it 'packs value into AIS bits' do
      expect(subject.pack.length).to eq(42)
    end
  end
end
