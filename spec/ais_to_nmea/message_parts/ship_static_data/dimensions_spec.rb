# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::ShipStaticData::Dimensions do
  it 'is defined' do
    expect(described_class).not_to be_nil
  end

  describe 'dimension parts' do
    it 'defines all expected dimension fields' do
      expect(described_class.constants).to include(:A, :B, :C, :D)
    end

    it 'uses message part base classes' do
      [described_class::A, described_class::B, described_class::C, described_class::D].each do |klass|
        expect(klass < AisToNmea::MessageParts::Base).to be(true)
      end
    end

    it 'packs each field with the expected bit width' do
      bit_widths = [described_class::A, described_class::B, described_class::C, described_class::D].map do |klass|
        klass.new(1).pack.length
      end

      expect(bit_widths).to eq([9, 9, 6, 6])
    end
  end
end
