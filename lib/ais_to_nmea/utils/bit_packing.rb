module AisToNmea
  module AisEncoder
    module Utils
      module BitPacking
        def self.pack_uint(value, width)
          raise InvalidFieldError, "Value #{value} does not fit in #{width} bits" if value.negative? || value >= (1 << width)

          value.to_s(2).rjust(width, '0')
        end

        def self.pack_signed(value, width)
          min = -(1 << (width - 1))
          max = (1 << (width - 1)) - 1
          raise InvalidFieldError, "Signed value #{value} does not fit in #{width} bits" unless value.between?(min, max)

          encoded = value.negative? ? ((1 << width) + value) : value
          encoded.to_s(2).rjust(width, '0')
        end
      end
    end
  end
end
