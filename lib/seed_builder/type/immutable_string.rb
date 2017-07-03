module SeedBuilder
  module Type
    class ImmutableString < Base
      def generate
        "immutable string".freeze
      end
    end
  end
end
