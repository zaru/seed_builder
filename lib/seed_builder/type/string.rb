module SeedBuilder
  module Type
    class String < Base
      def value
        valid_data
      end

      def random_generate length = 10
        o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map { |i| i.to_a }.flatten
        (0...length).map { o[rand(o.length)] }.join
      end

      private

      def valid_data
        value = random_generate
        @attr.valid_rules.each do |rule|
          value = rule.value self, value
        end
        value
      end
    end
  end
end
