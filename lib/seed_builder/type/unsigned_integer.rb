module SeedBuilder
  module Type
    class Boolean < Base
      def value
        rand(1000) + 1
      end
    end
  end
end
