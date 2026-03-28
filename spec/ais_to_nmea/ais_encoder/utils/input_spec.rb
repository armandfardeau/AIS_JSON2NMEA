# frozen_string_literal: true

require 'spec_helper'

describe AisToNmea::AisEncoder::Utils::Input do
  describe '.value_for_key' do
    it 'finds value using string key' do
      present, value = described_class.value_for_key({ 'Sog' => 12.3 }, 'Sog')

      expect(present).to be(true)
      expect(value).to eq(12.3)
    end

    it 'finds value using symbol fallback' do
      present, value = described_class.value_for_key({ Sog: 12.3 }, 'Sog')

      expect(present).to be(true)
      expect(value).to eq(12.3)
    end

    it 'returns not present when key does not exist' do
      present, value = described_class.value_for_key({}, 'Sog')

      expect(present).to be(false)
      expect(value).to be_nil
    end
  end

  describe '.first_available' do
    it 'returns first matching key and value' do
      key, value = described_class.first_available({ 'SpeedOverGround' => 4.2 }, 'Sog', 'SpeedOverGround')

      expect(key).to eq('SpeedOverGround')
      expect(value).to eq(4.2)
    end

    it 'returns nil pair when no key is present' do
      expect(described_class.first_available({}, 'A', 'B')).to eq([nil, nil])
    end
  end

  describe '.required_int' do
    it 'coerces integer-like values' do
      expect(described_class.required_int({ 'UserID' => '123' }, 'UserID')).to eq(123)
    end

    it 'raises missing field error' do
      expect { described_class.required_int({}, 'UserID') }
        .to raise_error(AisToNmea::MissingFieldError, /UserID/)
    end

    it 'raises invalid integer error' do
      expect { described_class.required_int({ 'UserID' => '12x' }, 'UserID') }
        .to raise_error(AisToNmea::InvalidFieldError, /Invalid integer value/)
    end
  end

  describe '.required_int_from' do
    it 'reads first available key from aliases' do
      value = described_class.required_int_from(
        { 'CourseOverGround' => '254' },
        %w[Cog CourseOverGround],
        field_name: 'Cog'
      )

      expect(value).to eq(254)
    end
  end

  describe '.optional_int_from' do
    it 'returns default when all aliases are missing' do
      value = described_class.optional_int_from({}, ['RepeatIndicator'], field_name: 'RepeatIndicator', default: 0)

      expect(value).to eq(0)
    end

    it 'raises on invalid integer for optional field' do
      expect do
        described_class.optional_int_from(
          { 'RepeatIndicator' => 'bad' },
          ['RepeatIndicator'],
          field_name: 'RepeatIndicator',
          default: 0
        )
      end.to raise_error(AisToNmea::InvalidFieldError, /Invalid integer value/)
    end
  end

  describe '.required_float' do
    it 'coerces numeric strings to float' do
      expect(described_class.required_float({ 'Latitude' => '48.8566' }, 'Latitude')).to eq(48.8566)
    end

    it 'raises invalid numeric error' do
      expect { described_class.required_float({ 'Latitude' => 'north' }, 'Latitude') }
        .to raise_error(AisToNmea::InvalidFieldError, /Invalid numeric value/)
    end
  end

  describe '.required_float_from' do
    it 'supports aliased float field names' do
      value = described_class.required_float_from(
        { Sog: '8.5' },
        %w[Sog SpeedOverGround],
        field_name: 'Sog'
      )

      expect(value).to eq(8.5)
    end
  end

  describe '.optional_bool_from' do
    it 'returns default when keys are absent' do
      value = described_class.optional_bool_from({}, ['PositionAccuracy'], field_name: 'PositionAccuracy', default: false)

      expect(value).to be(false)
    end

    it 'normalizes accepted boolean representations' do
      expect(
        described_class.optional_bool_from({ 'Dte' => 1 }, ['Dte'], field_name: 'Dte', default: false)
      ).to be(true)
      expect(
        described_class.optional_bool_from({ 'Dte' => '0' }, ['Dte'], field_name: 'Dte', default: true)
      ).to be(false)
      expect(
        described_class.optional_bool_from({ 'Dte' => 'TRUE' }, ['Dte'], field_name: 'Dte', default: false)
      ).to be(true)
      expect(
        described_class.optional_bool_from({ 'Dte' => 'false' }, ['Dte'], field_name: 'Dte', default: true)
      ).to be(false)
    end

    it 'raises on unsupported boolean representations' do
      expect do
        described_class.optional_bool_from({ 'Dte' => 'yes' }, ['Dte'], field_name: 'Dte', default: false)
      end.to raise_error(AisToNmea::InvalidFieldError, /Invalid boolean value/)
    end
  end
end
