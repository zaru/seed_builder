module SeedBuilder
  module Type
    class String < Base
      def value
        poly_keys = polymorphic_keys @model
        rel = poly_keys.select{|poly| @key == assoc[:key]}.first
        if rel
          rel[:klasses].sample.to_s
        else
          "it's string value."
        end
      end
    end
  end
end
