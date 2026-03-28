# frozen_string_literal: true

require 'spec_helper'

describe AisToNmea do
  ship_static_data_base_input = {
    'MessageID' => 5,
    'RepeatIndicator' => 0,
    'UserID' => 123_456_789,
    'Valid' => true,
    'AisVersion' => 0,
    'ImoNumber' => 9_876_543,
    'CallSign' => 'FRA1234',
    'Name' => 'TEST VESSEL',
    'Type' => 70,
    'Dimension' => { 'A' => 50, 'B' => 20, 'C' => 5, 'D' => 5 },
    'FixType' => 1,
    'Eta' => { 'Month' => 12, 'Day' => 31, 'Hour' => 23, 'Minute' => 59 },
    'MaximumStaticDraught' => 7.4,
    'Destination' => 'LE HAVRE',
    'Dte' => false,
    'Spare' => false
  }.freeze
  position_alias_input = {
    'Valid' => true,
    'RepeatIndicator' => 0,
    'UserID' => 601_967_000,
    'NavigationStatus' => 8,
    'Rot' => 128,
    'Latitude' => -34.14586666666666,
    'Longitude' => 18.230756666666665,
    'SpeedOverGround' => 6.3,
    'PositionAccuracy' => false,
    'CourseOverGround' => 182.3,
    'TrueHeading' => 180,
    'Timestamp' => 0,
    'Maneuver' => 0,
    'Spare' => 0,
    'Raim' => false,
    'RadioStatus' => 0
  }.freeze
  position_symbol_input = {
    MessageID: 1,
    RepeatIndicator: 0,
    UserID: 601_600_400,
    Valid: true,
    NavigationalStatus: 0,
    RateOfTurn: 128,
    Latitude: -33.904673333333335,
    Longitude: 18.422055,
    Sog: 0,
    PositionAccuracy: false,
    Cog: 262.8,
    TrueHeading: 511,
    Timestamp: 0,
    SpecialManoeuvreIndicator: 0,
    Spare: 0,
    Raim: false,
    CommunicationState: 0
  }.freeze
  position_optional_fields_input = {
    'RepeatIndicator' => 2,
    'UserID' => 555_555_555,
    'Valid' => true,
    'NavigationalStatus' => 5,
    'RateOfTurn' => 64,
    'Sog' => 14.2,
    'PositionAccuracy' => true,
    'Longitude' => 2.1501,
    'Latitude' => 41.3902,
    'Cog' => 89.4,
    'TrueHeading' => 90,
    'Timestamp' => 58,
    'SpecialManoeuvreIndicator' => 1,
    'Spare' => 3,
    'Raim' => true,
    'CommunicationState' => 123_456
  }.freeze

  def position_report_input(overrides = {})
    position_report_base_input.merge(overrides)
  end

  def safety_broadcast_input(overrides = {})
    safety_broadcast_base_input.merge(overrides)
  end

  def position_report_base_input
    position_report_identity_fields.merge(position_report_navigation_fields)
  end

  def position_report_identity_fields
    position_report_header_fields.merge(position_report_motion_fields)
  end

  def position_report_header_fields
    {
      'MessageID' => 1,
      'RepeatIndicator' => 0,
      'UserID' => 123_456_789,
      'Valid' => true,
      'NavigationalStatus' => 0
    }
  end

  def position_report_motion_fields
    {
      'RateOfTurn' => 128,
      'Latitude' => 48.8566,
      'Longitude' => 2.3522,
      'Sog' => 12.3
    }
  end

  def position_report_navigation_fields
    {
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

  def safety_broadcast_base_input
    {
      'MessageID' => 14,
      'RepeatIndicator' => 0,
      'UserID' => 123_456_789,
      'Valid' => true,
      'Spare' => 0,
      'Text' => 'SECURITE NAVIGATION'
    }
  end

  ship_static_data_input = ->(overrides = {}) { ship_static_data_base_input.merge(overrides) }

  def nmea_fields(result)
    result.split("\n").first[1..(result.split("\n").first.index('*') - 1)].split(',')
  end

  def nmea_checksum_matches?(result)
    sentence = result.split("\n").first
    content = sentence[1..(sentence.index('*') - 1)]
    checksum_expected = sentence[(sentence.index('*') + 1)..].to_i(16)
    checksum_actual = content.each_char.reduce(0) { |acc, c| acc ^ c.ord }
    checksum_actual == checksum_expected
  end

  def nested_safety_broadcast_input(text)
    {
      'MessageType' => 'SafetyBroadcastMessage',
      'Message' => safety_broadcast_input('Text' => text)
    }
  end

  fixtures_path = File.join(__dir__, 'fixtures', 'sample_ais_messages.json')
  fixtures = JSON.parse(File.read(fixtures_path))
  message_id_for = lambda do |input|
    next nil unless input.is_a?(Hash)

    input['MessageID'] || input.dig('Message', 'MessageID')
  end
  position_report_messages = fixtures['messages'].select do |test_case|
    [1, 2, 3].include?(message_id_for.call(test_case['input']))
  end
  position_report_error_cases = fixtures['error_cases'].select do |test_case|
    message_id = message_id_for.call(test_case['input'])
    message_id.nil? || [1, 2, 3].include?(message_id)
  end
  safety_broadcast_messages = fixtures['messages'].select { |test_case| message_id_for.call(test_case['input']) == 14 }
  safety_broadcast_error_cases = fixtures['error_cases'].select do |test_case|
    message_id_for.call(test_case['input']) == 14
  end

  describe '.to_nmea' do
    it 'returns a String for shorthand encoding' do
      expect(described_class.to_nmea(position_report_input)).to be_a(String)
    end

    it 'produces an AIVDM sentence for shorthand encoding' do
      expect(described_class.to_nmea(position_report_input)).to start_with('!AIVDM')
    end

    it 'registers position_report encoder key' do
      expect(AisToNmea::EncoderFactory.registered).to include(:position_report)
    end

    it 'uses encoder factory with explicit encoder key' do
      expect(described_class.to_nmea(position_report_input, encoder: :position_report)).to start_with('!AIVDM')
    end

    it 'routes MessageID 14 to SafetyBroadcastMessage encoder' do
      result = described_class.to_nmea(safety_broadcast_input)
      expect(result).to start_with('!AIVDM')
    end

    it 'routes MessageID 5 to ShipStaticData encoder' do
      result = described_class.to_nmea(ship_static_data_input.call)
      expect(result).to start_with('!AIVDM')
    end
  end

  describe AisToNmea::EncoderFactory do
    it 'builds default encoder (position report)' do
      encoder = described_class.build
      expect(encoder).to be_a(AisToNmea::Encoders::PositionReport)
    end

    it 'builds safety broadcast encoder' do
      encoder = described_class.build(encoder: :safety_broadcast_message)
      expect(encoder).to be_a(AisToNmea::Encoders::SafetyBroadcastMessage)
    end

    it 'builds ship static data encoder' do
      encoder = described_class.build(encoder: :ship_static_data)
      expect(encoder).to be_a(AisToNmea::Encoders::ShipStaticData)
    end

    it 'supports custom registered encoder' do
      custom = Class.new { def encode(_input, _options = {}) = "!AIVDM,1,1,0,A,CUSTOMPAYLOAD,0*00\n" }
      described_class.register(:custom, custom)
      encoder = described_class.build(encoder: :custom)
      expect(encoder.encode({})).to start_with('!AIVDM')
    end

    it 'raises for unknown encoder key' do
      expect { described_class.build(encoder: :unknown) }
        .to raise_error(AisToNmea::InvalidFieldError)
    end
  end

  describe AisToNmea::Encoder do
    subject(:encoder) { described_class.new }

    it 'routes Position Report message types' do
      result = encoder.encode(position_report_input)
      expect(result).to start_with('!AIVDM')
    end

    it 'routes Safety Broadcast messages' do
      result = encoder.encode(safety_broadcast_input)
      expect(result).to start_with('!AIVDM')
    end

    it 'routes ShipStaticData messages' do
      result = encoder.encode(ship_static_data_input.call)
      expect(result).to start_with('!AIVDM')
    end
  end

  describe AisToNmea::Encoders::PositionReport do
    subject(:encoder) { described_class.new }

    it 'raises UnsupportedMessageTypeError for non-position-report message IDs' do
      expect { encoder.encode(ship_static_data_input.call) }
        .to raise_error(AisToNmea::UnsupportedMessageTypeError, /PositionReport/)
    end

    context 'with valid Position Report messages' do
      position_report_messages.each do |test_case|
        it "handles #{test_case['name']} as String" do
          expect(encoder.encode(test_case['input'])).to be_a(String)
        end

        it "handles #{test_case['name']} with AIVDM prefix" do
          expect(encoder.encode(test_case['input'])).to match(/^!AIVDM/)
        end

        it "handles #{test_case['name']} with checksum suffix" do
          expect(encoder.encode(test_case['input'])).to match(/\*[0-9A-F]{2}$/)
        end

        it "handles #{test_case['name']} as JSON string result type" do
          json_input = JSON.generate(test_case['input'])
          expect(encoder.encode(json_input)).to be_a(String)
        end

        it "handles #{test_case['name']} as JSON string prefix" do
          json_input = JSON.generate(test_case['input'])
          expect(encoder.encode(json_input)).to match(/^!AIVDM/)
        end
      end

      it 'accepts legacy aliased keys for speed, course and navigation status' do
        result = encoder.encode(position_report_input(position_alias_input))
        expect(result).to start_with('!AIVDM')
      end

      it 'accepts symbol keys from upstream pipelines' do
        result = encoder.encode(position_symbol_input)
        expect(result).to start_with('!AIVDM')
      end

      it 'accepts explicit optional fields and communication state alias' do
        result = encoder.encode(position_report_input(position_optional_fields_input))
        expect(result).to start_with('!AIVDM')
      end

      it 'accepts Cog equal to 360.0 by normalizing it to 0.0' do
        normalized_result = described_class.new.encode(position_report_input('Cog' => 360.0))
        zero_result = described_class.new.encode(position_report_input('Cog' => 0.0))

        expect(normalized_result).to eq(zero_result)
      end
    end

    context 'with invalid input' do
      position_report_error_cases.each do |test_case|
        it "raises #{test_case['error_type']} for: #{test_case['name']}" do
          error_class = Object.const_get("AisToNmea::#{test_case['error_type']}")
          expect do
            encoder.encode(test_case['input'])
          end.to raise_error(error_class)
        end
      end

      it 'raises clear COG alias range error when course is invalid' do
        expect { encoder.encode(position_report_input('Cog' => 400.0, 'NavigationStatus' => 0)) }
          .to raise_error(AisToNmea::InvalidFieldError, %r{Cog/CourseOverGround})
      end

      it 'rejects invalid Valid flag set to false' do
        expect { encoder.encode(position_report_input('Valid' => false)) }
          .to raise_error(AisToNmea::InvalidFieldError, /Valid/)
      end

      it 'raises MissingFieldError when RepeatIndicator is omitted' do
        input = position_report_input.except('RepeatIndicator')
        expect { encoder.encode(input) }
          .to raise_error(AisToNmea::MissingFieldError, /RepeatIndicator/)
      end
    end

    context 'with invalid input type' do
      it 'raises InvalidJsonError for non-string, non-Hash input' do
        expect do
          encoder.encode(123)
        end.to raise_error(AisToNmea::InvalidJsonError)
      end
    end

    context 'when validating NMEA format' do
      let(:valid_input) { position_report_input }
      let(:fields) { nmea_fields(encoder.encode(valid_input)) }

      it 'returns NMEA sentences starting with !AIVDM' do
        result = encoder.encode(valid_input)
        expect(result).to start_with('!AIVDM')
      end

      it 'includes checksum after *' do
        expect(encoder.encode(valid_input).split('*').length).to eq(2)
      end

      it 'formats checksum as two uppercase hex characters' do
        checksum = encoder.encode(valid_input).split('*')[1]
        expect(checksum).to match(/^[0-9A-F]{2}/)
      end

      it 'has valid NMEA structure' do
        expect(fields[0]).to eq('AIVDM')
      end

      it 'uses channel A in NMEA fields' do
        expect(fields[4]).to eq('A')
      end

      it 'has positive sentence counters' do
        expect(fields[1].to_i).to be >= 1
      end

      it 'has positive sentence index' do
        expect(fields[2].to_i).to be >= 1
      end

      it 'has non-negative sequence id and non-empty payload' do
        expect(fields[3].to_i).to be >= 0
      end

      it 'has non-empty payload field' do
        expect(fields[5]).not_to be_empty
      end

      it 'calculates correct checksums' do
        expect(nmea_checksum_matches?(encoder.encode(valid_input))).to be(true)
      end
    end

    context 'when handling multi-part messages' do
      it 'returns multi-part messages separated by newlines' do
        sentences = encoder.encode(position_report_input).split("\n")
        expect(sentences).to all(start_with('!AIVDM'))
      end

      it 'returns sentences with valid checksum suffixes' do
        sentences = encoder.encode(position_report_input).split("\n")
        expect(sentences).to all(match(/\*[0-9A-F]{2}$/))
      end
    end
  end

  describe AisToNmea::MessageType do
    describe '.detect' do
      it 'detects message type 1 from Hash' do
        input = { 'MessageID' => 1 }
        expect(described_class.detect(input)).to eq(1)
      end

      it 'detects message type 1 from JSON string' do
        input = '{"MessageID": 1}'
        expect(described_class.detect(input)).to eq(1)
      end

      it 'detects message type from nested Message.MessageID' do
        input = { 'Message' => { 'MessageID' => 2 } }
        expect(described_class.detect(input)).to eq(2)
      end

      it 'detects message type 3' do
        input = { 'MessageID' => 3 }
        expect(described_class.detect(input)).to eq(3)
      end

      it 'detects message type 14' do
        input = { 'MessageID' => 14 }
        expect(described_class.detect(input)).to eq(14)
      end

      it 'detects message type 5' do
        input = { 'MessageID' => 5 }
        expect(described_class.detect(input)).to eq(5)
      end

      it 'raises UnsupportedMessageTypeError for type 4' do
        input = { 'MessageID' => 4 }
        expect do
          described_class.detect(input)
        end.to raise_error(AisToNmea::UnsupportedMessageTypeError)
      end

      it 'raises MissingFieldError if MessageID is missing' do
        input = { 'UserID' => 123 }
        expect do
          described_class.detect(input)
        end.to raise_error(AisToNmea::MissingFieldError)
      end

      it 'raises InvalidJsonError for malformed JSON string' do
        input = '{invalid json}'
        expect do
          described_class.detect(input)
        end.to raise_error(AisToNmea::InvalidJsonError)
      end
    end

    describe '.parse_input' do
      it 'parses JSON string to Hash' do
        input = '{"key": "value"}'
        result = described_class.parse_input(input)
        expect(result).to eq({ 'key' => 'value' })
      end

      it 'returns Hash as-is' do
        input = { 'key' => 'value' }
        result = described_class.parse_input(input)
        expect(result).to eq(input)
      end

      it 'raises InvalidJsonError for malformed JSON' do
        input = '{bad json}'
        expect do
          described_class.parse_input(input)
        end.to raise_error(AisToNmea::InvalidJsonError)
      end

      it 'raises InvalidJsonError for unsupported input types' do
        expect do
          described_class.parse_input(123)
        end.to raise_error(AisToNmea::InvalidJsonError)
      end
    end
  end

  describe AisToNmea::Encoders::SafetyBroadcastMessage do
    subject(:encoder) { described_class.new }

    context 'with valid SafetyBroadcastMessage fixtures' do
      safety_broadcast_messages.each do |test_case|
        it "handles #{test_case['name']} as String" do
          expect(encoder.encode(test_case['input'])).to be_a(String)
        end

        it "handles #{test_case['name']} with AIVDM prefix" do
          expect(encoder.encode(test_case['input'])).to start_with('!AIVDM')
        end

        it "handles #{test_case['name']} with checksum suffix" do
          expect(encoder.encode(test_case['input'])).to match(/\*[0-9A-F]{2}$/)
        end

        it "handles #{test_case['name']} as JSON string result type" do
          json_input = JSON.generate(test_case['input'])
          expect(encoder.encode(json_input)).to be_a(String)
        end

        it "handles #{test_case['name']} as JSON string prefix" do
          json_input = JSON.generate(test_case['input'])
          expect(encoder.encode(json_input)).to start_with('!AIVDM')
        end
      end
    end

    it 'encodes a valid SafetyBroadcastMessage as String' do
      input = safety_broadcast_input('RepeatIndicator' => 0, 'Spare' => 0)
      expect(encoder.encode(input)).to be_a(String)
    end

    it 'encodes a valid SafetyBroadcastMessage with AIVDM prefix' do
      input = safety_broadcast_input('RepeatIndicator' => 0, 'Spare' => 0)
      expect(encoder.encode(input)).to start_with('!AIVDM')
    end

    it 'encodes a valid SafetyBroadcastMessage with checksum suffix' do
      input = safety_broadcast_input('RepeatIndicator' => 0, 'Spare' => 0)
      expect(encoder.encode(input)).to match(/\*[0-9A-F]{2}$/)
    end

    it 'raises MissingFieldError when Text is missing' do
      expect { encoder.encode(safety_broadcast_input.except('Text')) }.to raise_error(AisToNmea::MissingFieldError)
    end

    it 'raises MissingFieldError when RepeatIndicator is missing' do
      expect { encoder.encode(safety_broadcast_input.except('RepeatIndicator')) }
        .to raise_error(AisToNmea::MissingFieldError, /RepeatIndicator/)
    end

    it 'raises InvalidFieldError when Valid is false' do
      expect { encoder.encode(safety_broadcast_input('Valid' => false)) }
        .to raise_error(AisToNmea::InvalidFieldError, /Valid/)
    end

    it 'raises InvalidFieldError for unsupported characters' do
      expect { encoder.encode(safety_broadcast_input('Text' => 'ALERTE~')) }.to raise_error(AisToNmea::InvalidFieldError)
    end

    context 'with invalid SafetyBroadcastMessage fixtures' do
      safety_broadcast_error_cases.each do |test_case|
        it "raises #{test_case['error_type']} for: #{test_case['name']}" do
          error_class = Object.const_get("AisToNmea::#{test_case['error_type']}")
          expect do
            encoder.encode(test_case['input'])
          end.to raise_error(error_class)
        end
      end
    end

    it 'accepts boundary values for RepeatIndicator and Spare' do
      result = encoder.encode(
        safety_broadcast_input('RepeatIndicator' => 3, 'Spare' => 3, 'Text' => 'BOUNDARY SAFETY MESSAGE')
      )
      expect(result).to start_with('!AIVDM')
    end

    it 'accepts Text at the 156-character limit' do
      result = encoder.encode(safety_broadcast_input('Text' => 'A' * 156))
      expect(result).to start_with('!AIVDM')
    end

    it 'accepts nested Message format for SafetyBroadcastMessage' do
      result = encoder.encode(nested_safety_broadcast_input('NESTED SAFETY MESSAGE'))
      expect(result).to start_with('!AIVDM')
    end
  end

  describe AisToNmea::Encoders::ShipStaticData do
    subject(:encoder) { described_class.new }

    describe '#encode' do
      it 'encodes a valid ShipStaticData message as String' do
        expect(encoder.encode(ship_static_data_input.call)).to be_a(String)
      end

      it 'encodes a valid ShipStaticData message with AIVDM prefix' do
        expect(encoder.encode(ship_static_data_input.call)).to start_with('!AIVDM')
      end

      it 'encodes a valid ShipStaticData message with checksum suffix' do
        expect(encoder.encode(ship_static_data_input.call)).to match(/\*[0-9A-F]{2}$/)
      end

      it 'raises MissingFieldError when Name is missing' do
        expect { encoder.encode(ship_static_data_input.call.except('Name')) }
          .to raise_error(AisToNmea::MissingFieldError)
      end
    end
  end

  describe 'Error classes' do
    it 'has InvalidJsonError' do
      expect { raise AisToNmea::InvalidJsonError, 'test' }.to raise_error(AisToNmea::InvalidJsonError)
    end

    it 'has MissingFieldError' do
      expect { raise AisToNmea::MissingFieldError, 'test' }.to raise_error(AisToNmea::MissingFieldError)
    end

    it 'has InvalidFieldError' do
      expect { raise AisToNmea::InvalidFieldError, 'test' }.to raise_error(AisToNmea::InvalidFieldError)
    end

    it 'has UnsupportedMessageTypeError' do
      expect { raise AisToNmea::UnsupportedMessageTypeError, 'test' }.to raise_error(AisToNmea::UnsupportedMessageTypeError)
    end

    it 'has EncodingError' do
      expect { raise AisToNmea::EncodingError, 'test' }.to raise_error(AisToNmea::EncodingError)
    end

    it 'has MemoryError' do
      expect { raise AisToNmea::MemoryError, 'test' }.to raise_error(AisToNmea::MemoryError)
    end
  end
end
