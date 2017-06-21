module SeedBuilder
  module Type
    class Datetime < Base

      def initialize active_model_type
      end

      def generate
        Time.now
      end
    end
  end
end
