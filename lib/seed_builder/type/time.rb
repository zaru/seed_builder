module SeedBuilder
  module Type
    class Time < Base
      def generate
        ::Time.now
      end
    end
  end
end
