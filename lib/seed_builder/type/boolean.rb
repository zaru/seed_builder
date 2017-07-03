module SeedBuilder
  module Type
    class Boolean < Base
      def generate
        [true, false].sample
      end
    end
  end
end
