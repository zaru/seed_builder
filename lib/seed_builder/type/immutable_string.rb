module SeedBuilder
  module Type
    class ImmutableString < Base
      def value
        "immutable string".freeze
      end
    end
  end
end
