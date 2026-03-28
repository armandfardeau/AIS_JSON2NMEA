# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'AisToNmea::VERSION' do
  it 'is a String' do
    expect(AisToNmea::VERSION).to be_a(String)
  end

  it 'is not empty' do
    expect(AisToNmea::VERSION).not_to be_empty
  end
end
