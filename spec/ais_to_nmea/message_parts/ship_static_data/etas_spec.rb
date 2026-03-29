# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::ShipStaticData::Etas do
  it 'is defined' do
    expect(described_class).not_to be_nil
  end

  it 'exposes ETA component classes' do
    components = [described_class::Month, described_class::Day, described_class::Hour, described_class::Minute]
    inheritance = components.map do |klass|
      klass < AisToNmea::MessageParts::Base
    end

    expect(inheritance).to eq([true, true, true, true])
  end

  it 'packs ETA components to a 20-bit payload when composed' do
    parts = [described_class::Month, described_class::Day, described_class::Hour, described_class::Minute]
    values = [12, 31, 23, 59]
    bits = parts.zip(values).map { |klass, value| klass.new(value).pack }

    expect(bits.join.length).to eq(20)
  end
end
