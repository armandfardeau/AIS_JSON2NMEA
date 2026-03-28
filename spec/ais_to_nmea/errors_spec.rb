# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::Error do
  it 'inherits from StandardError' do
    expect(described_class.superclass).to eq(StandardError)
  end

  it 'links JSON and field errors to the base error' do
    expect(AisToNmea::InvalidJsonError.superclass).to eq(described_class)
    expect(AisToNmea::MissingFieldError.superclass).to eq(described_class)
    expect(AisToNmea::InvalidFieldError.superclass).to eq(described_class)
  end

  it 'links message and encoding errors to the expected parents' do
    expect(AisToNmea::UnsupportedMessageTypeError.superclass).to eq(described_class)
    expect(AisToNmea::EncodingError.superclass).to eq(described_class)
    expect(AisToNmea::EncodingFailureError.superclass).to eq(AisToNmea::EncodingError)
    expect(AisToNmea::MemoryError.superclass).to eq(described_class)
  end
end
