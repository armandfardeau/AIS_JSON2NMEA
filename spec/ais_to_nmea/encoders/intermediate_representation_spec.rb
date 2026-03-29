# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::Encoders::IntermediateRepresentation do
  describe '.build' do
    subject(:result) { described_class.build(data, mapping) }

    let(:data) do
      {
        'message_id' => 1,
        'position' => {
          'latitude' => 37.7749,
          'longitude' => -122.4194
        }
      }
    end
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

    it 'builds nested structs from mapping entries', :aggregate_failures do
      expect(result.message_id).to eq(1)
      expect(result.position.latitude).to eq(37.7749)
      expect(result.position.longitude).to eq(-122.4194)
    end

    context 'when nested source data is missing' do
      let(:data) do
        {
          'message_id' => 1
        }
      end

      it 'builds nested structs with nil leaf values instead of crashing', :aggregate_failures do
        expect(result.message_id).to eq(1)
        expect(result.position.latitude).to be_nil
        expect(result.position.longitude).to be_nil
      end
    end

    context 'when root source data is nil' do
      let(:data) { nil }

      it 'returns a struct with nil mapped values', :aggregate_failures do
        expect(result.message_id).to be_nil
        expect(result.position.latitude).to be_nil
        expect(result.position.longitude).to be_nil
      end
    end
  end
end
