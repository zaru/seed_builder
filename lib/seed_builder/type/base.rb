module SeedBuilder
  module Type
    class Base

      def initialize
      end

      def generate
        raise "Please implement this method. #{self}"
      end
    end
  end
end
