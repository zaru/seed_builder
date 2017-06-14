module SeedBuilder
  module Type
    class Float < Base
      def value
        max = 100
        min = 1
        rand * (max-min) + min
      end
    end
  end
end
