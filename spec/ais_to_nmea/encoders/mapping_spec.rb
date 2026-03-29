# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::Encoders::Mapping do
  describe '.parts_mapping' do
    let(:context_name) { 'PositionReport' }
    let(:mapping_config_path) { '/tmp/mapping.yml' }

    it 'returns normalized mapping with symbols and constants' do
      allow(YAML).to receive(:safe_load_file).with(mapping_config_path, aliases: true).and_return(
        'position_report' => {
          'message_id' => {
            'field' => 'MessageID',
            'class' => 'AisToNmea::MessageParts::Common::MessageId'
          }
        }
      )

      mapping = described_class.parts_mapping(context_name: context_name, mapping_config_path: mapping_config_path)

      expect(mapping).to eq(
        message_id: {
          field: 'MessageID',
          class: AisToNmea::MessageParts::Common::MessageId
        }
      )
    end

    it 'raises InvalidFieldError when mapped class does not exist' do
      allow(YAML).to receive(:safe_load_file).with(mapping_config_path, aliases: true).and_return(
        'position_report' => {
          'message_id' => {
            'field' => 'MessageID',
            'class' => 'AisToNmea::MessageParts::Common::DoesNotExist'
          }
        }
      )

      expect do
        described_class.parts_mapping(context_name: context_name, mapping_config_path: mapping_config_path)
      end.to raise_error(AisToNmea::InvalidFieldError, /Unknown class in parts mapping/)
    end

    it 'raises InvalidFieldError when an entry defines neither class nor nested' do
      allow(YAML).to receive(:safe_load_file).with(mapping_config_path, aliases: true).and_return(
        'position_report' => {
          'message_id' => {
            'field' => 'MessageID'
          }
        }
      )

      expect do
        described_class.parts_mapping(context_name: context_name, mapping_config_path: mapping_config_path)
      end.to raise_error(AisToNmea::InvalidFieldError, /define either class or nested/)
    end
  end
end
