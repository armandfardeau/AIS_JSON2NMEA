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
        "SpeedOverGround" => 12.3,
        "CourseOverGround" => 254.8,
        "TrueHeading" => 255
      }

      result = AisToNmea.to_nmea(input)
      expect(result).to be_a(String)
      expect(result).to start_with('!AIVDM')
    end
  end

  describe AisToNmea::Encoder do
    subject { described_class.new }

    describe '#encode' do
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
            "SpeedOverGround" => 12.3,
            "CourseOverGround" => 254.8,
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
            "SpeedOverGround" => 12.3,
            "CourseOverGround" => 254.8,
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
