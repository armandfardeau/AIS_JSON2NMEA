# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Layout/LineLength, RSpec/ExampleLength

RSpec.describe AisToNmea::Encoders::OutputValidator do
  subject(:validator) { described_class }

  let(:position_report_fixtures) { fixture_json(message_type: :position_report) }
  let(:base_station_fixtures) { fixture_json(message_type: :base_station_report) }
  let(:ship_static_fixtures) { fixture_json(message_type: :ship_static_data) }
  let(:safety_broadcast_fixtures) { fixture_json(message_type: :safety_broadcast_message) }

  def normalized_position_report_input(name)
    input = position_report_fixtures.fetch('messages').find { |test_case| test_case['name'] == name }.fetch('input').dup
    input['PositionAccuracy'] = input['PositionAccuracy'] ? 1 : 0 if [true, false].include?(input['PositionAccuracy'])
    input['Raim'] = input['Raim'] ? 1 : 0 if [true, false].include?(input['Raim'])
    input
  end

  def normalized_ship_static_input
    ship_static_fixtures.fetch('messages').find { |test_case| test_case.dig('input', 'MessageID') == 5 }.fetch('input').dup
  end

  def normalized_base_station_input
    input = base_station_fixtures.fetch('messages').find { |test_case| test_case.dig('input', 'MessageID') == 4 }.fetch('input').dup
    input['PositionAccuracy'] = input['PositionAccuracy'] ? 1 : 0 if [true, false].include?(input['PositionAccuracy'])
    input['Raim'] = input['Raim'] ? 1 : 0 if [true, false].include?(input['Raim'])
    input
  end

  def safety_broadcast_input(name)
    safety_broadcast_fixtures.fetch('messages').find { |test_case| test_case['name'] == name }.fetch('input')
  end

  it 'validates a position report round-trip against the YAML mapping' do
    encoder = AisToNmea::Encoders::PositionReport.new(data: normalized_position_report_input('Complete PositionReport with explicit optional fields'))

    expect { validator.validate!(encoder.instance_variable_get(:@data), encoder.encode) }.not_to raise_error
  end

  it 'validates a ship static data round-trip against the YAML mapping subset' do
    encoder = AisToNmea::Encoders::ShipStaticData.new(data: normalized_ship_static_input)

    expect { validator.validate!(encoder.instance_variable_get(:@data), encoder.encode) }.not_to raise_error
  end

  it 'validates a base station report round-trip against the YAML mapping' do
    encoder = AisToNmea::Encoders::BaseStationReport.new(data: normalized_base_station_input)

    expect { validator.validate!(encoder.instance_variable_get(:@data), encoder.encode) }.not_to raise_error
  end

  it 'validates a safety broadcast message round-trip against the YAML mapping' do
    encoder = AisToNmea::Encoders::SafetyBroadcastMessage.new(
      data: safety_broadcast_input('Type 14 - SafetyBroadcastMessage complete')
    )

    expect { validator.validate!(encoder.instance_variable_get(:@data), encoder.encode) }.not_to raise_error
  end

  it 'raises an invalid field error when a mapped value differs' do
    encoder = AisToNmea::Encoders::PositionReport.new(data: normalized_position_report_input('Type 1 - Position Report'))
    output = encoder.encode
    mismatched_data = encoder.instance_variable_get(:@data).dup
    mismatched_data.mmsi = 999_999_999

    expect { validator.validate!(mismatched_data, output) }
      .to raise_error(AisToNmea::InvalidFieldError, /Validation failed for mmsi/)
  end

  it 'validates position report when COG is unavailable sentinel 360.0' do
    input = {
      'MessageID' => 1,
      'RepeatIndicator' => 0,
      'UserID' => 710_008_251,
      'NavigationalStatus' => 0,
      'RateOfTurn' => -128,
      'Sog' => 0.0,
      'PositionAccuracy' => true,
      'Longitude' => -59.92232833333333,
      'Latitude' => -3.1211866666666666,
      'Cog' => 360.0,
      'TrueHeading' => 511,
      'Timestamp' => 33,
      'SpecialManoeuvreIndicator' => 0,
      'Spare' => 0,
      'Raim' => true,
      'CommunicationState' => 49_172
    }

    encoder = AisToNmea::Encoders::PositionReport.new(data: input)

    expect { validator.validate!(encoder.instance_variable_get(:@data), encoder.encode) }.not_to raise_error
  end

  it 'validates position report when SOG above 102.2 is encoded as unavailable sentinel 102.3' do
    input = {
      'MessageID' => 1,
      'RepeatIndicator' => 0,
      'UserID' => 710_008_252,
      'NavigationalStatus' => 0,
      'RateOfTurn' => -128,
      'Sog' => 200.0,
      'PositionAccuracy' => true,
      'Longitude' => -59.92232833333333,
      'Latitude' => -3.1211866666666666,
      'Cog' => 120.0,
      'TrueHeading' => 120,
      'Timestamp' => 33,
      'SpecialManoeuvreIndicator' => 0,
      'Spare' => 0,
      'Raim' => true,
      'CommunicationState' => 49_172
    }

    encoder = AisToNmea::Encoders::PositionReport.new(data: input)

    expect { validator.validate!(encoder.instance_variable_get(:@data), encoder.encode) }.not_to raise_error
  end

  it 'validates position report when timestamp is unavailable sentinel 60' do
    input = {
      'MessageID' => 1,
      'RepeatIndicator' => 0,
      'UserID' => 701_006_706,
      'NavigationalStatus' => 0,
      'RateOfTurn' => 0,
      'Sog' => 0.0,
      'PositionAccuracy' => true,
      'Longitude' => -58.38229833333333,
      'Latitude' => -34.574115,
      'Cog' => 218.5,
      'TrueHeading' => 301,
      'Timestamp' => 60,
      'SpecialManoeuvreIndicator' => 0,
      'Spare' => 0,
      'Raim' => false,
      'CommunicationState' => 230_363
    }

    encoder = AisToNmea::Encoders::PositionReport.new(data: input)

    expect { validator.validate!(encoder.instance_variable_get(:@data), encoder.encode) }.not_to raise_error
  end

  describe '#decode_output' do
    subject(:validator_instance) { described_class.new }

    let(:output) { '!AIVDM,1,1,,A,13aG?P001oP>H2POFfR5?wvt0000,0*13\n' }

    it 'falls back to NMEAPlus::Decoder when SourceDecoder yields no complete message' do
      source_decoder = instance_double(NMEAPlus::SourceDecoder)
      parsed_message_class = Class.new do
        def ais; end
      end
      parsed_message = instance_double(parsed_message_class)
      decoder = instance_double(NMEAPlus::Decoder)
      ais_payload = instance_double(Object)

      allow(parsed_message).to receive(:ais).and_return(ais_payload)
      allow(source_decoder).to receive(:each_complete_message)
      allow(NMEAPlus::SourceDecoder).to receive(:new).with(instance_of(StringIO)).and_return(source_decoder)
      allow(NMEAPlus::Decoder).to receive(:new).and_return(decoder)
      allow(decoder).to receive(:parse).with(output).and_return(parsed_message)

      expect(validator_instance.decode_output(output)).to eq(parsed_message)
    end

    it 'raises InvalidFieldError when output cannot be decoded' do
      source_decoder = instance_double(NMEAPlus::SourceDecoder)
      parsed_message_class = Class.new
      parsed_message = instance_double(parsed_message_class)
      decoder = instance_double(NMEAPlus::Decoder)

      allow(source_decoder).to receive(:each_complete_message)
      allow(NMEAPlus::SourceDecoder).to receive(:new).with(instance_of(StringIO)).and_return(source_decoder)
      allow(NMEAPlus::Decoder).to receive(:new).and_return(decoder)
      allow(decoder).to receive(:parse).with(output).and_return(parsed_message)

      expect { validator_instance.decode_output(output) }
        .to raise_error(AisToNmea::InvalidFieldError, /Unable to decode encoder output for validation/)
    end
  end
end
# rubocop:enable Layout/LineLength, RSpec/ExampleLength
