# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::Common::Valid do
  it 'normalizes the input value' do
    part = described_class.new(true)
    expect(part.value).to eq(true)
  end

  it 'accepts a valid value' do
    part = described_class.new(false)
    expect(part.validate!).to eq(part)
    expect(part.value).to eq('false')
  end

  it 'rejects an invalid value' do
    expect { described_class.new(nil).validate! }.to raise_error(AisToNmea::MissingFieldError)
  end

  describe '#pack' do
    subject { described_class.new('A') }

    it 'packs value into AIS bits' do
      expect(subject.pack.length).to eq(42)
    end
  end
end
