# frozen_string_literal: true

require 'spec_helper'

describe AisToNmea::AisEncoder::Utils::Input do
  describe '.required_int' do
    it 'coerces integer-like values' do
      expect(described_class.required_int('123', 'UserID')).to eq(123)
    end

    it 'raises missing field error' do
      expect { described_class.required_int(nil, 'UserID') }
        .to raise_error(AisToNmea::MissingFieldError, /UserID/)
    end

    it 'raises invalid integer error' do
      expect { described_class.required_int('12x', 'UserID') }
        .to raise_error(AisToNmea::InvalidFieldError, /Invalid integer value/)
    end
  end

  describe '.required_int_from' do
    it 'reads first available key from aliases' do
      expect(
        described_class.required_int_from('254' , field_name: 'Cog')
      ).to eq(254)
    end
  end

  describe '.optional_int_from' do
    it 'returns default when all aliases are missing' do
      value = described_class.optional_int_from(nil, field_name: 'RepeatIndicator', default: 0)

      expect(value).to eq(0)
    end

    it 'raises on invalid integer for optional field' do
      input = { 'RepeatIndicator' => 'bad' }
      expect { described_class.optional_int_from(input, field_name: 'RepeatIndicator', default: 0) }
        .to raise_error(AisToNmea::InvalidFieldError, /Invalid integer value/)
    end
  end

  describe '.required_float' do
    it 'coerces numeric strings to float' do
      expect(described_class.required_float('48.8566', 'Latitude')).to eq(48.8566)
    end

    it 'raises invalid numeric error' do
      expect { described_class.required_float('north', 'Latitude') }
        .to raise_error(AisToNmea::InvalidFieldError, /Invalid numeric value/)
    end
  end

  describe '.required_float_from' do
    it 'supports aliased float field names' do
      expect(described_class.required_float_from('8.5', field_name: 'Sog')).to eq(8.5)
    end
  end

  describe '.optional_bool_from' do
    it 'returns default when keys are absent' do
        field_name = 'PositionAccuracy'
      value = described_class.optional_bool_from(nil, field_name:, default: false)
      expect(value).to be(false)
    end

    it 'normalizes integer representations' do
      expect(described_class.optional_bool_from(1, field_name: 'Dte', default: false)).to be(true)
    end

    it 'normalizes string integer representations' do
      expect(described_class.optional_bool_from('0', field_name: 'Dte', default: true))
        .to be(false)
    end

    it 'normalizes string representations' do
      expect(described_class.optional_bool_from('TRUE', field_name: 'Dte', default: false))
        .to be(true)
    end

    it 'normalizes lowercase string representations' do
      expect(described_class.optional_bool_from('false', field_name: 'Dte', default: true))
        .to be(false)
    end

    it 'raises on unsupported boolean representations' do
      expect do
        described_class.optional_bool_from('yes', field_name: 'Dte', default: false)
      end.to raise_error(AisToNmea::InvalidFieldError, /Invalid boolean value/)
    end
  end
end
