module SeedBuilder
  module Validate
    class NumericalityValidator

      MAX = 2147483648

      def initialize odd: nil, even: nil
        @odd  = odd
        @even = even
      end

      def call data:, entity:, key:
        return rand_odd  if @odd
        return rand_even if @even
        MAX
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
