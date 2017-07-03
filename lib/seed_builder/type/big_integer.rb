module SeedBuilder
  module Type
    class BigInteger < Base
      def generate
        rand(9223372036854775806) + 1
      end
    end
  end
end
