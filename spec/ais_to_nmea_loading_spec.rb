# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea do
  it 'autoloads BitPacking utility constant' do
    expect(defined?(AisToNmea::AisEncoder::Utils::BitPacking)).to eq('constant')
  end

  it 'autoloads Input utility constant' do
    expect(defined?(AisToNmea::AisEncoder::Utils::Input)).to eq('constant')
  end

  it 'autoloads Nmea utility constant' do
    expect(defined?(AisToNmea::AisEncoder::Utils::Nmea)).to eq('constant')
  end

  it 'keeps encoder registry initialized' do
    expect(AisToNmea::EncoderFactory.registered).to include(
      :position_report,
      :ship_static_data,
      :safety_broadcast_message
    )
  end
end
