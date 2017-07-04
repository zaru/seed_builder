require 'faker'
require 'seed_builder/customized_faker'
require 'seed_builder/valid/string'
require 'seed_builder/valid/integer'

module SeedBuilder
  class ValidData


    def initialize type_name:, model_object:, key:
      @model_object = model_object
      # ex) String Text Integer...
      @type_name = type_name
      # ex) name, email...
      @key = key

      @valid_type = valid_type
    end

    def generate
      @valid_type.generate
    end

    private

    def valid_type
      case obj_type
      when :string
        return Valid::String.new model_object: @model_object, key: @key
      when :integer
        return Valid::Integer.new model_object: @model_object, key: @key
      else
        return @type = "SeedBuilder::Type::#{@type_name}".constantize.new
      end
    end

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
