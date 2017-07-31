module SeedBuilder
  module Valid
    class String
      def initialize model_object:, key:
        @model_object = model_object
        @key = key
      end

      def generate
        validator_names = validators.map{|m| m.class.name.demodulize}

        # When key is "email", ignore validations.
        return email_str if @key == "email"

        case validator_names

        when include_inclusion?
          return included_str

        when include_format?
          return formatted_str

        when include_numericality?
          first_str = rand(1..9).to_s
          rest_str = (1...num_of_chars).map{rand(0..9)}.join
          return data = first_str + rest_str

        else
          data = (1..num_of_chars).map{('a'..'z').to_a[rand(26)]}.join
          return data
        end
      end


      private

      def email_str
        "#{SecureRandom.hex(8)}@example.com"
      end

      def included_str
        arr = inclusion_validator.options[:in]
        arr.sample
      end

      def formatted_str
        # NOTE: 複数の FormatValidator が存在しうるが、それを考慮するのは、
        # 大変すぎる気がするので、一番最後のものだけを反映させてます。ひとまず..
        regex = format_validators.map{|m| m.options[:with]}.last
        RegexSample.generate(regex)
      end

      def validators
        @model_object._validators[@key.to_sym]
      end

      def length_validators
        validators.select{ |m|
          m.class.name.demodulize == "LengthValidator"
        }
      end

      # NOTE: Use last validator
      def inclusion_validator
        validators.select{ |m|
          m.class.name.demodulize == "InclusionValidator"
        }.last
      end

      def format_validators
        validators.select{ |m|
          m.class.name.demodulize == "FormatValidator"
        }
      end

      # @return [Integer] 文字数
      def num_of_chars
        # ex) {:minimum=>5, :maximum=>9}
        merged_options = length_validators.map(&:options).inject({}, :merge)

        minimum = merged_options[:minimum] || 0
        maximum = merged_options[:maximum] || 16
        rand(minimum..maximum)
      end


      def include_inclusion?
        ->(arr){ arr.include? "InclusionValidator" }
      end

      def include_format?
        ->(arr){ arr.include? "FormatValidator" }
      end

      def include_numericality?
        ->(arr){ arr.include? "NumericalityValidator" }
      end

      def include_length?
        ->(arr){ arr.include? "LengthValidator" }
      end
    end
  end
end
