# frozen_string_literal: true

require 'spec_helper'

describe AisToNmea::Encodings::Text do
  describe '.encode_ais_text' do
    it 'encodes uppercase characters to 6-bit chunks' do
      bits = described_class.encode_ais_text('AB', max_length: 10)

      expect(bits).to eq('000001000010')
    end

    it 'upcases input before encoding' do
      bits = described_class.encode_ais_text('ab', max_length: 10)

      expect(bits).to eq('000001000010')
    end

    it 'raises when text is nil' do
      expect { described_class.encode_ais_text(nil, max_length: 10) }
        .to raise_error(AisToNmea::MissingFieldError, /Text/)
    end

    it 'raises when text is too long' do
      expect { described_class.encode_ais_text('ABCDE', max_length: 4) }
        .to raise_error(AisToNmea::InvalidFieldError, /too long/)
    end

    it 'raises on unsupported AIS characters' do
      expect { described_class.encode_ais_text('HELLO{', max_length: 10) }
        .to raise_error(AisToNmea::InvalidFieldError, /Unsupported AIS character/)
    end
  end

  describe '.encode_ais_text_fixed' do
    it 'pads with @ to fixed length' do
      bits = described_class.encode_ais_text_fixed('A', length: 3, field_name: 'CallSign')

      expect_bit_string(bits, 18)
      expect(bits).to eq('000001000000000000')
    end

    it 'raises when fixed field is missing' do
      expect { described_class.encode_ais_text_fixed(nil, length: 3, field_name: 'Name') }
        .to raise_error(AisToNmea::MissingFieldError, /Name/)
    end

    it 'raises on invalid characters with field context' do
      expect { described_class.encode_ais_text_fixed('N{', length: 3, field_name: 'Name') }
        .to raise_error(AisToNmea::InvalidFieldError, /Unsupported AIS character in Name/)
    end
  end
end
