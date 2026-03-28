# frozen_string_literal: true

require 'spec_helper'

describe AisToNmea::MessageParts::PositionReport::Latitude do
  describe 'instance chaining API' do
    it 'supports extract -> validate! -> pack chaining' do
      bits = described_class.new('Latitude' => 48.8566).extract.validate!.pack

      expect(bits).to be_a(String)
      expect(bits.length).to eq(27)
      expect(bits).to match(/\A[01]+\z/)
    end

    it 'raises MissingFieldError when Latitude is missing' do
      expect do
        described_class.new({}).extract
      end.to raise_error(AisToNmea::MissingFieldError, /Latitude/)
    end

    it 'raises InvalidFieldError when latitude is out of range' do
      expect do
        described_class.new('Latitude' => 95.0).extract.validate!
      end.to raise_error(AisToNmea::InvalidFieldError, /Latitude must be between -90 and 90/)
    end
  end

  describe 'without class API' do
    it 'does not expose class extraction helpers anymore' do
      expect(described_class).not_to respond_to(:extract)
      expect(described_class).not_to respond_to(:validate!)
      expect(described_class).not_to respond_to(:pack)
    end
  end
end
