module SeedBuilder
  module Type
    class Base

      def initialize active_model_type
      end

      def generate
        raise "Please implement this method. #{self}"
      end
    end
  end
end
