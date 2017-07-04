module SeedBuilder
  module Valid
    class Integer

      def initialize model_object:, key:
      end

      def generate
        rand(9999)
      end

    end
  end
end
