module AisToNmea
  module AisEncoder
    module Utils
      module SixBit
        def self.encode(bit_string)
          fill_bits = (6 - (bit_string.length % 6)) % 6
          padded = bit_string + ('0' * fill_bits)
          payload = padded.scan(/.{6}/).map { |chunk| char(chunk.to_i(2)) }.join
          [payload, fill_bits]
        end

        def self.char(value)
          c = value + 48
          c += 8 if c > 87
          c.chr
        end
      end
    end
  end
end
