module SeedBuilder
  module Type
    class Boolean < Base
      def generate
        Time.now
      end
    end
  end
end
