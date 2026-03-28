# frozen_string_literal: true

require 'spec_helper'

describe AisToNmea::AisEncoder::Utils::Nmea do
  describe '.checksum' do
    it 'computes XOR checksum as uppercase hex' do
      expect(described_class.checksum('ABC')).to eq('40')
    end
  end

  describe '.build_sentences' do
    it 'builds a single NMEA sentence with AIVDM prefix' do
      sentence = described_class.build_sentences('A' * 10, 2)
      expect(sentence).to start_with('!AIVDM,1,1,0,A,')
    end

    it 'includes fill bits marker in single sentence' do
      sentence = described_class.build_sentences('A' * 10, 2)
      expect(sentence).to include(',2*')
    end

    it 'adds trailing newline in single sentence output' do
      sentence = described_class.build_sentences('A' * 10, 2)
      expect(sentence).to end_with("\n")
    end

    it 'splits payload in chunks of 60' do
      sentence = described_class.build_sentences('A' * 61, 5)
      lines = sentence.split("\n").reject(&:empty?)
      expect(lines.length).to eq(2)
    end

    it 'uses fill bits 0 for non-final chunk' do
      sentence = described_class.build_sentences('A' * 61, 5)
      lines = sentence.split("\n").reject(&:empty?)
      expect(lines[0]).to include(',0*')
    end

    it 'keeps fill bits on final chunk' do
      sentence = described_class.build_sentences('A' * 61, 5)
      lines = sentence.split("\n").reject(&:empty?)
      expect(lines[1]).to include(',5*')
    end
  end
end
