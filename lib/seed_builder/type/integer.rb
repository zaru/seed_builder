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
        val = random_generate
        # TODO: validateモジュールにルールを移植する
        @model.validators.select{|v| v.attributes.include?(@key.to_sym) }.each do |v|
          if v.is_a? ActiveModel::Validations::NumericalityValidator
            val = rand_odd if v.options[:odd]
            val = rand_even if v.options[:even]
          end
        end
        val
      end

      def rand_odd
        rand(MAX / 2) * 2 + 1
      end

      def rand_even
        rand(MAX / 2) * 2
      end
    end
  end
end
