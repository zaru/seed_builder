module SeedBuilder
  module Type
    class Boolean < Base
      def value
        Time.now
      end
    end
  end
end
