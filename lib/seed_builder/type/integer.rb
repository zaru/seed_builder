module SeedBuilder
  module Type
    class Integer < Base

      MAX = 2147483648

      def value
        if @attr.foreign_key?
          @attr.foreign_klass.all.sample.id # めっちゃ非効率
        else
          valid_data
        end
      end

      def random_generate
        rand(MAX) + 1
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
