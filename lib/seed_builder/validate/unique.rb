module SeedBuilder
  module Validate
    class Unique

      def initialize model:, attr_key:
        @model = model
        @attr_key = attr_key
      end

      def value type_obj, value = ""
        unique_val = lambda do |val|
          @model.find_by({ @attr_key => val}) ? (unique_val.call(type_obj.random_generate)) : val
        end
        unique_val.call type_obj.random_generate
      end
    end
  end
end