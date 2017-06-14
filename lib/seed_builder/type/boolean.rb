module SeedBuilder
  module Type
    class Boolean < Base
      def value
        [true, false].sample
      end
    end
  end
end
