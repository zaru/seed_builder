module SeedBuilder
  module Type
    class String < Base
      def value
        # TODO: ここのポリモーフィック用の処理、もう必要ない気がするので検証する
        # poly_keys = polymorphic_keys @model
        # rel = poly_keys.select{|poly| @key == poly[:key]}.first
        # if rel
        #   rel[:klasses].sample.to_s
        # else
        #   valid_data
        # end
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
