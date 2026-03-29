# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::Encoders::Base do
  it 'is defined' do
    expect(described_class).not_to be_nil
  end

  describe '#parts_mapping' do
    subject(:encoder) { described_class.allocate }

    it 'delegates mapping lookup to Mapping with context and config path', :aggregate_failures do
      allow(AisToNmea::Encoders::Mapping).to receive(:parts_mapping).and_return({})

      encoder.parts_mapping

      expect(AisToNmea::Encoders::Mapping).to have_received(:parts_mapping).with(
        context_name: 'Base',
        mapping_config_path: described_class::MAPPING_CONFIG_PATH
      )
    end

    it 'memoizes mapping lookup results' do
      allow(AisToNmea::Encoders::Mapping).to receive(:parts_mapping).and_return({ message_id: {} })

      first = encoder.parts_mapping
      second = encoder.parts_mapping

      expect(first).to eq(second)
      expect(AisToNmea::Encoders::Mapping).to have_received(:parts_mapping).once
    end
  end
end
