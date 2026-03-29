# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::BaseStationReport::UtcMinute do
  it 'normalizes the input value' do
    expect(described_class.new('34').value).to eq(34)
  end

  it 'accepts a valid value' do
    part = described_class.new(34)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(60).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  it 'packs value into AIS bits' do
    expect(described_class.new(34).pack.length).to eq(6)
  end
end
