# frozen_string_literal: true

module AisToNmea
  module AisEncoder
    module Utils
      module Nmea
        def self.build_sentences(payload, fill_bits)
          max_payload = 60
          parts = payload.scan(/.{1,#{max_payload}}/)
          total = parts.length
          seq_id = 0

          result = parts.each_with_index.map do |part, idx|
            part_fill = idx == total - 1 ? fill_bits : 0
            content = "AIVDM,#{total},#{idx + 1},#{seq_id},A,#{part},#{part_fill}"
            checksum = checksum(content)
            "!#{content}*#{checksum}"
          end.join("\n")

          "#{result}\n"
        end

        def self.checksum(content)
          value = content.each_byte.reduce(0) { |acc, byte| acc ^ byte }
          format('%02X', value)
        end
      end
    end
  end
end
