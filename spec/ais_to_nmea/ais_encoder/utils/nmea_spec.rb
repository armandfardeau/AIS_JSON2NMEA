# frozen_string_literal: true

require 'spec_helper'

describe AisToNmea::AisEncoder::Utils::Nmea do
  describe '.checksum' do
    it 'computes XOR checksum as uppercase hex' do
      expect(described_class.checksum('ABC')).to eq('40')
    end
  end

  describe '.build_sentences' do
    it 'builds a single NMEA sentence with trailing newline' do
      sentence = described_class.build_sentences('A' * 10, 2)

      expect(sentence).to start_with('!AIVDM,1,1,0,A,')
      expect(sentence).to include(',2*')
      expect(sentence).to end_with("\n")
    end

    it 'splits payload in chunks of 60 and keeps fill bits only on final part' do
      sentence = described_class.build_sentences('A' * 61, 5)
      lines = sentence.split("\n").reject(&:empty?)

      expect(lines.length).to eq(2)
      expect(lines[0]).to include('!AIVDM,2,1,0,A,')
      expect(lines[0]).to include(',0*')
      expect(lines[1]).to include('!AIVDM,2,2,0,A,')
      expect(lines[1]).to include(',5*')
    end
  end
end
