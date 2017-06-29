module SeedBuilder
  class ValidData

    def initialize type:, model_object:, key:
      @type         = type
      @model_object = model_object
      @key          = key
    end

    def generate
      case obj_type
      when :string
        ("a".."z").to_a.sample(30).join
      when :integer
        rand(9999)
      end
    end

    private

    # @return [Symbol] :string or :integer
    def obj_type
      string_type  = %w( String Text )
      integer_type = %w( Integer BigInteger Decimal )
      case @type
      when *string_type
        :string
      when *integer_type
        :integer
      end
    end

  end
end
