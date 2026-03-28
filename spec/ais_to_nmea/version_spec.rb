# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'AisToNmea::VERSION' do
  it 'is defined and not empty' do
    expect(AisToNmea::VERSION).to be_a(String)
    expect(AisToNmea::VERSION).not_to be_empty
  end
end
