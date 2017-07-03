module SeedBuilder
  module Type
    class Boolean < Base
      def generate
        rand(1000) + 1
      end
    end
  end
end
