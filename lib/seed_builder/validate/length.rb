module SeedBuilder
  module Validate
    class Length

      def initialize model:, attr_key:, options: {}
        @entity = model
        @attr_key = attr_key
        @minimum = options[:minimum] || 0
        @maximum = options[:maximum] || 255
      end

      def value type_obj, value = ""
        # TODO: String型しか想定していないので他のも必要であれば対応する
        return value.ljust @maximum, "a" if value.size < @minimum
        return value[0, @maximum - 1] if value.size > @maximum
        value
      end

    end
  end
end