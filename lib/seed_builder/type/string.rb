module SeedBuilder
  module Type
    class String < Base
      def value
        poly_keys = polymorphic_keys @model
        rel = poly_keys.select{|poly| @key == poly[:key]}.first
        if rel
          # TODO: ここのリレーション用処理、もう必要ない気がする
          rel[:klasses].sample.to_s
        else
          valid_data
        end
      end

      private

      # TODO: 本来は他のルールも考慮しながらフィルタ的にデータを生成する仕組みに変更する
      def valid_data
        @model.validators.select{|v| v.attributes.include?(@key.to_sym) }.each do |v|
          if v.is_a? ActiveRecord::Validations::UniquenessValidator
            unique_string = lambda do |str|
              @model.find_by({ @key => str}) ? (unique_string.call(random_generate)) : str
            end
            return unique_string.call random_generate
          else
            return random_generate
          end
        end
      end

      def random_generate length = 10
        o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map { |i| i.to_a }.flatten
        (0...length).map { o[rand(o.length)] }.join
      end
    end
  end
end
