# frozen_string_literal: true

module AisToNmea
  module AisEncoder
    module Utils
      # Base class shared by all AIS encoder implementations.
      module IntermediateRepresentation
        # Build an intermediate representation of the data based on the provided mapping.
        # This allows for easier access to nested fields and a more structured way to handle the data.
        # @param data [Hash] The input data hash
        # @param mapping [Hash] The mapping that defines how to extract fields from the data
        # @return [Struct] A structured representation of the data based on the mapping
        def self.build(data, mapping)
          data = mapping.values.map do |mapping|
            if mapping[:nested]
              build(data[mapping[:field]], mapping[:nested])
            else
              data[mapping[:field]]
            end
          end

          Struct.new(*mapping.keys).new(*data)
        end
      end
    end
  end
end
