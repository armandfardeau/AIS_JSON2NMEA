# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::BaseStationReport::UtcDay do
  it 'normalizes the input value' do
    expect(described_class.new('29').value).to eq(29)
  end

  it 'accepts a valid value' do
    part = described_class.new(29)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(32).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  it 'packs value into AIS bits' do
    expect(described_class.new(29).pack.length).to eq(5)
  end
end
