# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::BaseStationReport::UtcYear do
  it 'normalizes the input value' do
    expect(described_class.new('2026').value).to eq(2026)
  end

  it 'accepts a valid value' do
    part = described_class.new(2026)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(10_000).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  it 'packs value into AIS bits' do
    expect(described_class.new(2026).pack.length).to eq(14)
  end
end
