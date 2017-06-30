module SeedBuilder
  class ValidData

    def initialize type_name:, model_object:, key:
      @model_object = model_object
      # ex) String Text Integer...
      @type_name = type_name
      # ex) name, email...
      @key = key
    end

    def generate
      case obj_type
      when :string
        ValidString.new(model_object: @model_object, key: @key).generate
      when :integer
        ValidInteger.new(model_object: @model_object, key: @key).generate
      else
        @type = "SeedBuilder::Type::#{@type_name}".constantize.new
        @type.generate
      end
    end


    class ValidString
      def initialize model_object:, key:
        @model_object = model_object
        @key = key
        validates
      end
      def generate
        ("a".."z").to_a.sample(30).join
      end

      private

      def validates
        validators = @model_object._validators[@key.to_sym]
        validator_names = validators.map{|m| m.class.name.demodulize}

        case validator_names
        when include_format?
          # TODO: Regex の拡張を作る予定
        when include_length?
          # TODO: Length この辺ごにょごにょしないといけない
        else
          # 何もしない
        end
      end

      def include_format?
        ->(arr){ arr.include? "FromatValidata" }
      end
      def include_length?
        ->(arr){ arr.include? "LengthValidator" }
      end
    end

    class ValidInteger
      def initialize model_object:, key:
      end
      def generate
        rand(9999)
      end
    end


    private

    # @return [Symbol] :string or :integer
    def obj_type
      string_type  = %w( String Text )
      integer_type = %w( Integer BigInteger Decimal )
      case @type_name
      when *string_type
        :string
      when *integer_type
        :integer
      end
    end

  end
end
