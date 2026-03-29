# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::BaseStationReport::Spare do
  it 'normalizes the input value' do
    expect(described_class.new('512').value).to eq(512)
  end

  it 'accepts a valid value' do
    part = described_class.new(512)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(1024).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  it 'packs value into AIS bits' do
    expect(described_class.new(512).pack.length).to eq(10)
  end
end
