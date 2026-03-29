# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::Encoders::InputParser do
  describe '.parse' do
    it 'returns hash input unchanged' do
      input = { 'MessageID' => 1 }

      expect(described_class.parse(input)).to eq(input)
    end

    it 'parses JSON string input into a hash' do
      result = described_class.parse('{"MessageID":1}')

      expect(result).to eq({ 'MessageID' => 1 })
    end

    it 'raises InvalidJsonError for invalid JSON strings' do
      expect do
        described_class.parse('{invalid json}')
      end.to raise_error(AisToNmea::InvalidJsonError, /Invalid JSON:/)
    end

    it 'raises InvalidJsonError for unsupported input types' do
      expect do
        described_class.parse(123)
      end.to raise_error(AisToNmea::InvalidJsonError, 'Input must be a JSON string or Hash')
    end
  end
end
