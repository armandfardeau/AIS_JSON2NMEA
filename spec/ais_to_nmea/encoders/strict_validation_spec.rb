# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::Encoders::StrictValidation do
  describe '.missing_required_fields' do
    let(:data) do
      Struct.new(:message_id, :position).new(
        message_id,
        Struct.new(:latitude, :longitude).new(latitude, longitude)
      )
    end
    let(:message_id) { nil }
    let(:latitude) { nil }
    let(:longitude) { 10.0 }
    let(:mapping) do
      {
        message_id: { field: 'message_id', class: Integer },
        position: {
          field: 'position',
          nested: {
            latitude: { field: 'latitude', class: Float },
            longitude: { field: 'longitude', class: Float }
          }
        }
      }
    end

    it 'returns missing fields across nested mappings' do
      expect(described_class.missing_required_fields(data, mapping)).to eq(%i[message_id latitude])
    end
  end

  describe '.raise_missing_fields!' do
    it 'raises MissingFieldError when required fields are missing' do
      data = Struct.new(:message_id).new(nil)
      mapping = {
        message_id: { field: 'message_id', class: Integer }
      }

      expect do
        described_class.raise_missing_fields!(context_name: 'PositionReport', data: data, mapping: mapping)
      end.to raise_error(AisToNmea::MissingFieldError, 'Missing required field(s) for PositionReport: message_id')
    end

    it 'does not raise when all required fields are present' do
      data = Struct.new(:message_id).new(1)
      mapping = {
        message_id: { field: 'message_id', class: Integer }
      }

      expect do
        described_class.raise_missing_fields!(context_name: 'PositionReport', data: data, mapping: mapping)
      end.not_to raise_error
    end
  end
end
