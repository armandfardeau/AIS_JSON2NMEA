# frozen_string_literal: true

require 'spec_helper'

describe AisToNmea::AisEncoder::SixBit do
  describe '.char' do
    it 'maps value 0 to ASCII 48 (0)' do
      expect(described_class.char(0)).to eq('0')
    end

    it 'applies AIS offset after 87' do
      expect(described_class.char(40)).to eq('`')
    end
  end

  describe '.encode' do
    it 'returns payload without padding when size is multiple of 6' do
      payload, _fill_bits = described_class.encode('000001000010')
      expect(payload).to eq('12')
    end

    it 'returns zero fill bits when size is multiple of 6' do
      _, fill_bits = described_class.encode('000001000010')
      expect(fill_bits).to eq(0)
    end

    it 'pads to nearest 6 bits in payload' do
      payload, _fill_bits = described_class.encode('101')
      expect(payload).to eq('`')
    end

    it 'reports fill bits after padding' do
      _, fill_bits = described_class.encode('101')
      expect(fill_bits).to eq(3)
    end

    it 'returns empty payload for empty bit string' do
      payload, _fill_bits = described_class.encode('')
      expect(payload).to eq('')
    end

    it 'returns zero fill bits for empty bit string' do
      _, fill_bits = described_class.encode('')
      expect(fill_bits).to eq(0)
    end
  end
end
