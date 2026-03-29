# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::Encoders::Mapping do
  describe '.parts_mapping' do
    subject(:mapping) do
      described_class.parts_mapping(context_name: context_name, mapping_config_path: mapping_config_path)
    end

    let(:context_name) { 'PositionReport' }
    let(:mapping_config_path) { '/tmp/mapping.yml' }
    let(:mapping_config) do
      {
        'position_report' => {
          'message_id' => {
            'field' => 'MessageID',
            'class' => 'AisToNmea::MessageParts::Common::MessageId'
          }
        }
      }
    end

    before do
      allow(YAML).to receive(:safe_load_file).with(mapping_config_path, aliases: true).and_return(mapping_config)
    end

    it 'returns normalized mapping with symbols and constants' do
      expect(mapping).to eq(
        message_id: {
          field: 'MessageID',
          class: AisToNmea::MessageParts::Common::MessageId
        }
      )
    end

    context 'with invalid mapping configuration' do
      let(:mapping_config) do
        { 'position_report' => {
          'message_id' => {
            'field' => 'MessageID',
            'class' => 'AisToNmea::MessageParts::Common::DoesNotExist'
          }
        } }
      end

      it 'raises InvalidFieldError when mapped class does not exist' do
        expect do
          described_class.parts_mapping(context_name: context_name, mapping_config_path: mapping_config_path)
        end.to raise_error(AisToNmea::InvalidFieldError, /Unknown class in parts mapping/)
      end
    end

    context 'with entry missing class and nested' do
      let(:mapping_config) do
        { 'position_report' => {
          'message_id' => {
            'field' => 'MessageID'
          }
        } }
      end

      it 'raises InvalidFieldError when an entry defines neither class nor nested' do
        expect do
          described_class.parts_mapping(context_name: context_name, mapping_config_path: mapping_config_path)
        end.to raise_error(AisToNmea::InvalidFieldError, /define either class or nested/)
      end
    end
  end
end
