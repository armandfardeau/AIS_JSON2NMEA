# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::Encoders::Base do
  it 'is defined' do
    expect(described_class).not_to be_nil
  end

  describe '.parts_mapping' do
    after do
      described_class.instance_variable_set(:@parts_mapping, nil)
    end

    it 'raises InvalidFieldError when mapped class does not exist' do
      allow(described_class).to receive(:all_parts_mappings).and_return(
        'base' => {
          'message_id' => {
            'field' => 'MessageID',
            'class' => 'AisToNmea::MessageParts::Common::DoesNotExist'
          }
        }
      )

      expect { described_class.parts_mapping }
        .to raise_error(AisToNmea::InvalidFieldError, /Unknown class in parts mapping/)
    end

    it 'raises InvalidFieldError when an entry defines neither class nor nested' do
      allow(described_class).to receive(:all_parts_mappings).and_return(
        'base' => {
          'message_id' => {
            'field' => 'MessageID'
          }
        }
      )

      expect { described_class.parts_mapping }
        .to raise_error(AisToNmea::InvalidFieldError, /define either class or nested/)
    end
  end
end
