# frozen_string_literal: true

require 'spec_helper'

describe AisToNmea::AisEncoder::BitPacking do
  describe '.pack_uint' do
    it 'packs 0 on full width' do
      expect(described_class.pack_uint(0, 6)).to eq('000000')
    end

    it 'packs max value for width' do
      expect(described_class.pack_uint(1023, 10)).to eq('1111111111')
    end

    it 'raises when value is negative' do
      expect { described_class.pack_uint(-1, 6) }
        .to raise_error(AisToNmea::InvalidFieldError, /does not fit/)
    end

    it 'raises when value overflows width' do
      expect { described_class.pack_uint(1024, 10) }
        .to raise_error(AisToNmea::InvalidFieldError, /does not fit/)
    end
  end

  describe '.pack_signed' do
    it 'packs minimum signed value' do
      expect(described_class.pack_signed(-64, 7)).to eq('1000000')
    end

    it 'packs maximum signed value' do
      expect(described_class.pack_signed(63, 7)).to eq('0111111')
    end

    it 'packs negative two-complement values' do
      expect(described_class.pack_signed(-1, 8)).to eq('11111111')
    end

    it 'raises when signed value is below minimum' do
      expect { described_class.pack_signed(-65, 7) }
        .to raise_error(AisToNmea::InvalidFieldError, /does not fit/)
    end

    it 'raises when signed value is above maximum' do
      expect { described_class.pack_signed(64, 7) }
        .to raise_error(AisToNmea::InvalidFieldError, /does not fit/)
    end
  end
end
