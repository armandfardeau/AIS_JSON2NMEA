# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::PositionReport::Rot do
  it 'is defined' do
    expect(described_class).not_to be_nil
  end

  it 'accepts -128 and packs it as 10000000' do
    rot = described_class.new(nil, -128)

    expect(rot.validate!.pack).to eq('10000000')
  end

  it 'rejects values below -128' do
    rot = described_class.new(nil, -129)

    expect { rot.validate! }.to raise_error(
      AisToNmea::InvalidFieldError,
      /Rot must be between -128 and 255/
    )
  end
end
