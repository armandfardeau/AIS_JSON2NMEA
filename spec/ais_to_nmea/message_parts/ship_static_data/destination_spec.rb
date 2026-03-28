# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::ShipStaticData::Destination do
  it 'normalizes the input value' do
    expect(described_class.new(123).value).to eq('123')
  end

  it 'accepts a valid value' do
    part = described_class.new('HAMBURG')
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(nil).validate! }.to raise_error(AisToNmea::MissingFieldError)
  end

  describe '#pack' do
    subject { described_class.new('HAMBURG') }

    it 'packs value into AIS bits' do
      expect(subject.pack.length).to eq(120)
    end
  end
end
