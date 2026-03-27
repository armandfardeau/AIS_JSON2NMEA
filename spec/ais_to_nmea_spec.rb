require 'spec_helper'

describe AisToNmea do
  fixtures_path = File.join(__dir__, 'fixtures', 'sample_ais_messages.json')
  fixtures = JSON.parse(File.read(fixtures_path))

  describe '.to_nmea' do
    it 'is a shorthand for Encoder.new.encode' do
      input = {
        "MessageID" => 1,
        "UserID" => 123456789,
        "Latitude" => 48.8566,
        "Longitude" => 2.3522,
        "Sog" => 12.3,
        "Cog" => 254.8,
        "TrueHeading" => 255
      }

      result = AisToNmea.to_nmea(input)
      expect(result).to be_a(String)
      expect(result).to start_with('!AIVDM')
    end

    it 'uses encoder factory with explicit encoder key' do
      input = {
        "MessageID" => 1,
        "UserID" => 123456789,
        "Latitude" => 48.8566,
        "Longitude" => 2.3522,
        "Sog" => 12.3,
        "Cog" => 254.8,
        "TrueHeading" => 255
      }

      expect(AisToNmea::EncoderFactory.registered).to include(:position_report)
      result = AisToNmea.to_nmea(input, encoder: :position_report)
      expect(result).to start_with('!AIVDM')
    end

    it 'routes MessageID 14 to SafetyBroadcastMessage encoder' do
      input = {
        "MessageID" => 14,
        "UserID" => 123456789,
        "Text" => 'SECURITE NAVIGATION'
      }

      result = AisToNmea.to_nmea(input)
      expect(result).to start_with('!AIVDM')
    end

    it 'routes MessageID 5 to ShipStaticData encoder' do
      input = {
        "MessageID" => 5,
        "UserID" => 123456789,
        "AisVersion" => 0,
        "ImoNumber" => 9876543,
        "CallSign" => 'FRA1234',
        "Name" => 'TEST VESSEL',
        "Type" => 70,
        "Dimension" => { "A" => 50, "B" => 20, "C" => 5, "D" => 5 },
        "FixType" => 1,
        "Eta" => { "Month" => 12, "Day" => 31, "Hour" => 23, "Minute" => 59 },
        "MaximumStaticDraught" => 7.4,
        "Destination" => 'LE HAVRE',
        "Dte" => false,
        "Spare" => false
      }

      result = AisToNmea.to_nmea(input)
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
      custom = Class.new do
        def encode(_input, _options = {})
          '!AIVDM,1,1,0,A,CUSTOMPAYLOAD,0*00\n'
        end
      end

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
    subject { described_class.new }

    it 'routes Position Report message types' do
      input = {
        "MessageID" => 1,
        "UserID" => 123456789,
        "Latitude" => 48.8566,
        "Longitude" => 2.3522,
        "Sog" => 12.3,
        "Cog" => 254.8,
        "TrueHeading" => 255
      }

      result = subject.encode(input)
      expect(result).to start_with('!AIVDM')
    end

    it 'routes Safety Broadcast messages' do
      input = {
        "MessageID" => 14,
        "UserID" => 123456789,
        "Text" => 'SECURITE NAVIGATION'
      }

      result = subject.encode(input)
      expect(result).to start_with('!AIVDM')
    end

    it 'routes ShipStaticData messages' do
      input = {
        "MessageID" => 5,
        "UserID" => 123456789,
        "AisVersion" => 0,
        "ImoNumber" => 9876543,
        "CallSign" => 'FRA1234',
        "Name" => 'TEST VESSEL',
        "Type" => 70,
        "Dimension" => { "A" => 50, "B" => 20, "C" => 5, "D" => 5 },
        "FixType" => 1,
        "Eta" => { "Month" => 12, "Day" => 31, "Hour" => 23, "Minute" => 59 },
        "MaximumStaticDraught" => 7.4,
        "Destination" => 'LE HAVRE',
        "Dte" => false,
        "Spare" => false
      }

      result = subject.encode(input)
      expect(result).to start_with('!AIVDM')
    end
  end

  describe AisToNmea::Encoders::PositionReport do
    subject { described_class.new }

    describe '#encode' do
      it 'raises UnsupportedMessageTypeError for non-position-report message IDs' do
        input = {
          "MessageID" => 5,
          "UserID" => 636024245,
          "AisVersion" => 2,
          "ImoNumber" => 9221827,
          "CallSign" => '5LRR4',
          "Name" => 'MSC SOPHIE VII',
          "Type" => 71,
          "Dimension" => { "A" => 243, "B" => 57, "C" => 26, "D" => 14 },
          "FixType" => 1,
          "Eta" => { "Day" => 26, "Hour" => 12, "Minute" => 0, "Month" => 3 },
          "MaximumStaticDraught" => 14.6,
          "Destination" => 'ZACPT',
          "Dte" => false,
          "Spare" => false
        }

        expect do
          subject.encode(input)
        end.to raise_error(AisToNmea::UnsupportedMessageTypeError, /PositionReport/)
      end

      context 'with valid Position Report messages' do
        fixtures['messages'].each do |test_case|
          it "handles #{test_case['name']}" do
            result = subject.encode(test_case['input'])

            expect(result).to be_a(String)
            expect(result).to match(/^!AIVDM/)
            expect(result).to match(/\*[0-9A-F]{2}$/)
          end

          it "handles #{test_case['name']} as JSON string" do
            json_input = JSON.generate(test_case['input'])
            result = subject.encode(json_input)

            expect(result).to be_a(String)
            expect(result).to match(/^!AIVDM/)
          end
        end

        it 'accepts legacy aliased keys for speed, course and navigation status' do
          input = {
            "MessageID" => 1,
            "UserID" => 601967000,
            "Latitude" => -34.14586666666666,
            "Longitude" => 18.230756666666665,
            "SpeedOverGround" => 6.3,
            "CourseOverGround" => 182.3,
            "NavigationalStatus" => 8,
            "TrueHeading" => 180
          }

          result = subject.encode(input)
          expect(result).to start_with('!AIVDM')
        end

        it 'accepts symbol keys from upstream pipelines' do
          input = {
            MessageID: 1,
            UserID: 601600400,
            Latitude: -33.904673333333335,
            Longitude: 18.422055,
            Sog: 0,
            Cog: 262.8,
            NavigationalStatus: 0,
            TrueHeading: 511
          }

          result = subject.encode(input)
          expect(result).to start_with('!AIVDM')
        end
      end

      context 'with invalid input' do
        fixtures['error_cases'].each do |test_case|
          it "raises #{test_case['error_type']} for: #{test_case['name']}" do
            error_class = Object.const_get("AisToNmea::#{test_case['error_type']}")
            expect do
              subject.encode(test_case['input'])
            end.to raise_error(error_class)
          end
        end

        it 'raises clear COG alias range error when course is invalid' do
          input = {
            "MessageID" => 1,
            "UserID" => 123456789,
            "Latitude" => 48.8566,
            "Longitude" => 2.3522,
            "Cog" => 400.0,
            "Sog" => 12.3,
            "TrueHeading" => 255,
            "NavigationStatus" => 0
          }

          expect do
            subject.encode(input)
          end.to raise_error(AisToNmea::InvalidFieldError, /Cog\/CourseOverGround/)
        end
      end

      context 'with invalid input type' do
        it 'raises InvalidJsonError for non-string, non-Hash input' do
          expect do
            subject.encode(123)
          end.to raise_error(AisToNmea::InvalidJsonError)
        end
      end

      context 'NMEA format validation' do
        let(:valid_input) do
          {
            "MessageID" => 1,
            "UserID" => 123456789,
            "Latitude" => 48.8566,
            "Longitude" => 2.3522,
            "Sog" => 12.3,
            "Cog" => 254.8,
            "TrueHeading" => 255
          }
        end

        it 'returns NMEA sentences starting with !AIVDM' do
          result = subject.encode(valid_input)
          expect(result).to start_with('!AIVDM')
        end

        it 'includes checksum after *' do
          result = subject.encode(valid_input)
          parts = result.split('*')
          expect(parts.length).to eq(2)
          expect(parts[1]).to match(/^[0-9A-F]{2}/)
        end

        it 'has valid NMEA structure' do
          result = subject.encode(valid_input)
          sentence = result.split("\n").first
          
          # Remove ! and checksum for analysis
          content = sentence[1..sentence.index('*') - 1]
          fields = content.split(',')

          expect(fields[0]).to eq('AIVDM')  # Sentence type
          expect(fields[1].to_i).to be >= 1  # Total sentences
          expect(fields[2].to_i).to be >= 1  # Sentence number
          expect(fields[3].to_i).to be >= 0  # Sequential message ID
          expect(fields[4]).to eq('A')       # Channel
          expect(fields[5]).not_to be_empty  # Payload
        end

        it 'calculates correct checksums' do
          result = subject.encode(valid_input)
          sentence = result.split("\n").first

          # Extract parts
          content = sentence[1..sentence.index('*') - 1]
          checksum_str = sentence[(sentence.index('*') + 1)..]
          checksum_expected = checksum_str.to_i(16)

          # Calculate checksum
          checksum_actual = 0
          content.each_char { |c| checksum_actual ^= c.ord }

          expect(checksum_actual).to eq(checksum_expected)
        end
      end

      context 'multi-part message handling' do
        it 'returns multi-part messages separated by newlines' do
          # Type 5 messages can be multi-part, but with types 1-3 this is less common
          # This test ensures proper formatting if multi-part occurs
          input = {
            "MessageID" => 1,
            "UserID" => 123456789,
            "Latitude" => 48.8566,
            "Longitude" => 2.3522,
            "Sog" => 12.3,
            "Cog" => 254.8,
            "TrueHeading" => 255
          }

          result = subject.encode(input)
          sentences = result.split("\n")

          sentences.each do |sentence|
            expect(sentence).to start_with('!AIVDM')
            expect(sentence).to match(/\*[0-9A-F]{2}$/)
          end
        end
      end
    end
  end

  describe AisToNmea::MessageType do
    describe '.detect' do
      it 'detects message type 1 from Hash' do
        input = { "MessageID" => 1 }
        expect(described_class.detect(input)).to eq(1)
      end

      it 'detects message type 1 from JSON string' do
        input = '{"MessageID": 1}'
        expect(described_class.detect(input)).to eq(1)
      end

      it 'detects message type from nested Message.MessageID' do
        input = { "Message" => { "MessageID" => 2 } }
        expect(described_class.detect(input)).to eq(2)
      end

      it 'detects message type 3' do
        input = { "MessageID" => 3 }
        expect(described_class.detect(input)).to eq(3)
      end

      it 'detects message type 14' do
        input = { "MessageID" => 14 }
        expect(described_class.detect(input)).to eq(14)
      end

      it 'detects message type 5' do
        input = { "MessageID" => 5 }
        expect(described_class.detect(input)).to eq(5)
      end

      it 'raises UnsupportedMessageTypeError for type 4' do
        input = { "MessageID" => 4 }
        expect do
          described_class.detect(input)
        end.to raise_error(AisToNmea::UnsupportedMessageTypeError)
      end

      it 'raises MissingFieldError if MessageID is missing' do
        input = { "UserID" => 123 }
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
        expect(result).to eq({ "key" => "value" })
      end

      it 'returns Hash as-is' do
        input = { "key" => "value" }
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
    subject { described_class.new }

    describe '#encode' do
      it 'encodes a valid SafetyBroadcastMessage' do
        input = {
          "MessageID" => 14,
          "RepeatIndicator" => 0,
          "UserID" => 123456789,
          "Spare" => 0,
          "Text" => 'SECURITE NAVIGATION'
        }

        result = subject.encode(input)
        expect(result).to be_a(String)
        expect(result).to start_with('!AIVDM')
        expect(result).to match(/\*[0-9A-F]{2}$/)
      end

      it 'raises MissingFieldError when Text is missing' do
        input = {
          "MessageID" => 14,
          "UserID" => 123456789
        }

        expect do
          subject.encode(input)
        end.to raise_error(AisToNmea::MissingFieldError)
      end

      it 'raises InvalidFieldError for unsupported characters' do
        input = {
          "MessageID" => 14,
          "UserID" => 123456789,
          "Text" => 'ALERTE~'
        }

        expect do
          subject.encode(input)
        end.to raise_error(AisToNmea::InvalidFieldError)
      end
    end
  end

  describe AisToNmea::Encoders::ShipStaticData do
    subject { described_class.new }

    describe '#encode' do
      it 'encodes a valid ShipStaticData message' do
        input = {
          "MessageID" => 5,
          "UserID" => 123456789,
          "AisVersion" => 0,
          "ImoNumber" => 9876543,
          "CallSign" => 'FRA1234',
          "Name" => 'TEST VESSEL',
          "Type" => 70,
          "Dimension" => { "A" => 50, "B" => 20, "C" => 5, "D" => 5 },
          "FixType" => 1,
          "Eta" => { "Month" => 12, "Day" => 31, "Hour" => 23, "Minute" => 59 },
          "MaximumStaticDraught" => 7.4,
          "Destination" => 'LE HAVRE',
          "Dte" => false,
          "Spare" => false
        }

        result = subject.encode(input)
        expect(result).to be_a(String)
        expect(result).to start_with('!AIVDM')
        expect(result).to match(/\*[0-9A-F]{2}$/)
      end

      it 'raises MissingFieldError when Name is missing' do
        input = {
          "MessageID" => 5,
          "UserID" => 123456789,
          "CallSign" => 'FRA1234',
          "Destination" => 'LE HAVRE'
        }

        expect do
          subject.encode(input)
        end.to raise_error(AisToNmea::MissingFieldError)
      end
    end
  end

  describe 'Error classes' do
    it 'has InvalidJsonError' do
      expect { raise AisToNmea::InvalidJsonError, "test" }.to raise_error(AisToNmea::InvalidJsonError)
    end

    it 'has MissingFieldError' do
      expect { raise AisToNmea::MissingFieldError, "test" }.to raise_error(AisToNmea::MissingFieldError)
    end

    it 'has InvalidFieldError' do
      expect { raise AisToNmea::InvalidFieldError, "test" }.to raise_error(AisToNmea::InvalidFieldError)
    end

    it 'has UnsupportedMessageTypeError' do
      expect { raise AisToNmea::UnsupportedMessageTypeError, "test" }.to raise_error(AisToNmea::UnsupportedMessageTypeError)
    end

    it 'has EncodingError' do
      expect { raise AisToNmea::EncodingError, "test" }.to raise_error(AisToNmea::EncodingError)
    end

    it 'has MemoryError' do
      expect { raise AisToNmea::MemoryError, "test" }.to raise_error(AisToNmea::MemoryError)
    end
  end
end
