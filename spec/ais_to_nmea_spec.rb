# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea do
  let(:position_report_input) do
    {
      'MessageID' => 1,
      'RepeatIndicator' => 0,
      'UserID' => 123_456_789,
      'Valid' => true,
      'NavigationalStatus' => 0,
      'RateOfTurn' => 128,
      'Latitude' => 48.8566,
      'Longitude' => 2.3522,
      'Sog' => 12.3,
      'PositionAccuracy' => false,
      'Cog' => 254.8,
      'TrueHeading' => 255,
      'Timestamp' => 0,
      'SpecialManoeuvreIndicator' => 0,
      'Spare' => 0,
      'Raim' => false,
      'CommunicationState' => 0
    }
  end

  describe AisToNmea::EncoderFactory do
    around do |example|
      registry = described_class.instance_variable_get(:@registry).dup
      example.run
      described_class.instance_variable_set(:@registry, registry)
    end

    let(:custom_encoder) do
      Class.new do
        def initialize(data: nil)
          @data = data
        end

        def encode
          "!AIVDM,1,1,0,A,CUSTOMPAYLOAD,0*00\n"
        end
      end
    end

    it 'builds position report encoder' do
      encoder = described_class.build(data: position_report_input, encoder: :position_report)
      expect(encoder).to be_a(AisToNmea::Encoders::PositionReport)
    end

    it 'supports custom registered encoder' do
      described_class.register(:custom, custom_encoder)
      encoder = described_class.build(data: {}, encoder: :custom)
      expect(encoder.encode).to start_with('!AIVDM')
    end

    it 'raises for unknown encoder key' do
      expect { described_class.build(data: position_report_input, encoder: :unknown) }
        .to raise_error(AisToNmea::InvalidFieldError)
    end
  end
end
