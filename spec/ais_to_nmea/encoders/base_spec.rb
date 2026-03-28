# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::Encoders::Base do
  it 'is defined' do
    expect(described_class).not_to be_nil
  end
end
