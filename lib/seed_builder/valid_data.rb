module SeedBuilder
  class ValidData

    def initialize type_name:, model_object:, key:
      @type_name    = type_name
      @model_object = model_object
      @key          = key
    end

    def generate
      case obj_type
      when :string
        ("a".."z").to_a.sample(30).join
      when :integer
        rand(9999)
      else
        @type = "SeedBuilder::Type::#{@type_name}".constantize.new
        @type.generate
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
