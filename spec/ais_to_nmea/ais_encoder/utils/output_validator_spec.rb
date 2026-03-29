# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Layout/LineLength, RSpec/ExampleLength

RSpec.describe AisToNmea::AisEncoder::Utils::OutputValidator do
  subject(:validator) { described_class }

  let(:position_report_fixtures) { fixture_json(message_type: :position_report) }
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
end
# rubocop:enable Layout/LineLength, RSpec/ExampleLength
