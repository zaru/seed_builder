module SeedBuilder
  module Type
    class Datetime < Base
      def value
        Time.now
      end
    end
  end
end
