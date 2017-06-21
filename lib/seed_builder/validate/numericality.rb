module SeedBuilder
  module Validate
    class Numericality

      MAX = 2147483648

      def initialize model:, attr_key:, options: {}
        @entity = model
        @attr_key = attr_key
        @options = options
      end

      def value type_obj, value = ""
        if @options[:odd]
          return rand_odd
        end

        if @options[:even]
          return rand_even
        end

        value
      end

      private

      def rand_odd
        rand(MAX / 2) * 2 + 1
      end

      def rand_even
        rand(MAX / 2) * 2
      end
    end
  end
end