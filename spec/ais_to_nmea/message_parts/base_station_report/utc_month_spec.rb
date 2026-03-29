# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::BaseStationReport::UtcMonth do
  it 'normalizes the input value' do
    expect(described_class.new('3').value).to eq(3)
  end

  it 'accepts a valid value' do
    part = described_class.new(3)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(13).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  it 'packs value into AIS bits' do
    expect(described_class.new(3).pack.length).to eq(4)
  end
end
