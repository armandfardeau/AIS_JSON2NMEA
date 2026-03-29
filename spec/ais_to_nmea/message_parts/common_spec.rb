# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::Common do
  it 'is defined' do
    expect(described_class).not_to be_nil
  end

  it 'is a module' do
    expect(described_class).to be_a(Module)
  end

  describe 'shared field classes' do
    it 'defines MessageId' do
      expect(described_class::MessageId).to be < AisToNmea::MessageParts::Base
    end

    it 'defines Mmsi' do
      expect(described_class::Mmsi).to be < AisToNmea::MessageParts::Base
    end
  end
end
