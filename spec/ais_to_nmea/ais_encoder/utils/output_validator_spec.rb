# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::AisEncoder::Utils::OutputValidator do
  subject(:validator) do
    Class.new do
      include AisToNmea::AisEncoder::Utils::OutputValidator
    end.new
  end

  let(:fixtures) { fixture_json('sample_ais_messages.json') }

  def normalized_position_report_input(name)
    input = fixtures.fetch('messages').find { |test_case| test_case['name'] == name }.fetch('input').dup
    input['SpeedOverGround'] = input.delete('Sog') if input.key?('Sog')
    input['CourseOverGround'] = input.delete('Cog') if input.key?('Cog')
    input['RadioStatus'] = input.delete('CommunicationState') if input.key?('CommunicationState')
    input['PositionAccuracy'] = input['PositionAccuracy'] ? 1 : 0 if [true, false].include?(input['PositionAccuracy'])
    input['Raim'] = input['Raim'] ? 1 : 0 if [true, false].include?(input['Raim'])
    input
  end

  def normalized_ship_static_input
    input = fixtures.fetch('messages').find { |test_case| test_case.dig('input', 'MessageID') == 5 }.fetch('input').dup
    input['AISVersion'] = input.delete('AisVersion') if input.key?('AisVersion')
    input['IMONumber'] = input.delete('ImoNumber') if input.key?('ImoNumber')
    input['ShipType'] = input.delete('Type') if input.key?('Type')
    input['DTE'] = input.delete('Dte') if input.key?('Dte')
    input
  end

  def safety_broadcast_input(name)
    fixtures.fetch('messages').find { |test_case| test_case['name'] == name }.fetch('input')
  end

  it 'validates a position report round-trip against the YAML mapping' do
    encoder = AisToNmea::Encoders::PositionReport.new(data: normalized_position_report_input('Complete PositionReport with explicit optional fields'))

    expect { validator.validate!(encoder.instance_variable_get(:@data), encoder.encode) }.not_to raise_error
  end

  it 'validates a ship static data round-trip against the YAML mapping subset' do
    encoder = AisToNmea::Encoders::ShipStaticData.new(data: normalized_ship_static_input)

    expect { validator.validate!(encoder.instance_variable_get(:@data), encoder.encode) }.not_to raise_error
  end

  it 'validates a safety broadcast message round-trip against the YAML mapping' do
    encoder = AisToNmea::Encoders::SafetyBroadcastMessage.new(data: safety_broadcast_input('Type 14 - SafetyBroadcastMessage complete'))

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
end
