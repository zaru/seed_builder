module SeedBuilder
  class Attribute

    attr_reader :key, :type, :model

    def initialize attr, model
      @key = attr.first
      @active_model_type = attr.last
      @type = @active_model_type.type
      @model = model
    end

    def valid_rules
      return @valid_rules unless @valid_rules.nil?
      @valid_rules = []
      if unique_index? || unique?
        @valid_rules << Validate::Unique
      end
      @valid_rules
    end

    def auto_generate?
      # TODO: Rails規約どおりの場合のみ想定しているのでカスタムに対応する
      "id" == @key
    end

    def sti_type?
      "type" == @key && @model.superclass != ActiveRecord::Base
    end

    private

    def unique_index?
      ActiveRecord::Base.connection.indexes(@model.table_name).select{|i| i.columns.include?(@key) && i.unique}.size.zero? ? false : true
    end

    def unique?
      @model.validators.select{|v| v.attributes.include?(@key.to_sym) && v.is_a?(ActiveRecord::Validations::UniquenessValidator) }.size.zero? ? false : true
    end

  end
end