# frozen_string_literal: true

module AisToNmea
  module AisEncoder
    module Utils
      # Helpers for building NMEA 0183 AIVDM sentences.
      module Nmea
        def self.build_sentences(payload, fill_bits)
          parts = payload.scan(/.{1,60}/)
          lines = parts.each_with_index.map { |part, idx| build_sentence(part, idx, parts.length, fill_bits) }
          "#{lines.join("\n")}\n"
        end

        def self.build_sentence(part, idx, total, fill_bits)
          part_fill = idx == total - 1 ? fill_bits : 0
          content = "AIVDM,#{total},#{idx + 1},0,A,#{part},#{part_fill}"
          "!#{content}*#{checksum(content)}"
        end

        def self.checksum(content)
          value = content.each_byte.reduce(0) { |acc, byte| acc ^ byte }
          format('%02X', value)
        end
      end
    end
  end
end
