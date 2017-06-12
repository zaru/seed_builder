module SeedBuilder
  module Type
    class Integer < Base
      def value
        assoc_keys = association_keys @model
        rel = assoc_keys.select{|assoc| @key == assoc[:key]}.first
        if rel
          rel[:klass].all.sample.id # めっちゃ非効率
        else
          rand(1000) + 1 # 適当な数値を返す
        end
      end
    end
  end
end
