# frozen_string_literal: true

require 'spec_helper'

describe AisToNmea::AisEncoder::Utils::SixBit do
  describe '.char' do
    it 'maps value 0 to ASCII 48 (0)' do
      expect(described_class.char(0)).to eq('0')
    end

    it 'applies AIS offset after 87' do
      expect(described_class.char(40)).to eq('`')
    end
  end

  describe '.encode' do
    it 'returns payload and fill bits without padding when size is multiple of 6' do
      payload, fill_bits = described_class.encode('000001000010')

      expect(payload).to eq('12')
      expect(fill_bits).to eq(0)
    end

    it 'pads to nearest 6 bits and reports fill bits' do
      payload, fill_bits = described_class.encode('101')

      expect(payload).to eq('`')
      expect(fill_bits).to eq(3)
    end

    it 'handles empty bit string' do
      payload, fill_bits = described_class.encode('')

      expect(payload).to eq('')
      expect(fill_bits).to eq(0)
    end
  end
end
