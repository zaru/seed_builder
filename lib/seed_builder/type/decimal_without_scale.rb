module SeedBuilder
  module Type
    class DecimalWithoutScale < Base
      def value
        max = 100
        min = 1
        rand * (max-min) + min
      end
    end
  end
end
