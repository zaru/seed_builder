module SeedBuilder
  class Attribute

    attr_reader :key, :type, :model

    def initialize attr, entity
      @key = attr.first
      @active_model_type = attr.last
      @type = @active_model_type.type
      @model = entity.model
      @entity = entity
    end

    def valid_rules
      return @valid_rules unless @valid_rules.nil?
      @valid_rules = []
      if unique_index? || unique?
        @valid_rules << Validate::Unique
      end
      @valid_rules
    end

    def foreign_key?
      # ポリモーフィックの外部キーはこの時点でリレーション先のモデルを確定できないので、普通のフィールドとして扱う
      return false if polymorphic_foreign_key?
      return true if @entity.foreign_keys.find{|f| @key == f[:foreign_key] }
      return true if "left_side_id" == @key
      false
    end

    def foreign_klass
      return nil if polymorphic_foreign_key?

      if foreign = @entity.foreign_keys.find{|f| @key == f[:foreign_key] }
        return foreign[:klass]
      end

      # TODO: left_side_id の対応
    end

    def auto_generate?
      # TODO: Rails規約どおりの場合のみ想定しているのでカスタムに対応する
      "id" == @key
    end

    def sti_type?
      "type" == @key && @model.superclass != ActiveRecord::Base
    end

    private

    def polymorphic_foreign_key?
      @entity.polymorphic_columns.find{|c| @key == c[:foreign_key] } ? true : false
    end

    def unique_index?
      ActiveRecord::Base.connection.indexes(@model.table_name).select{|i| i.columns.include?(@key) && i.unique}.size.zero? ? false : true
    end

    def unique?
      @model.validators.select{|v| v.attributes.include?(@key.to_sym) && v.is_a?(ActiveRecord::Validations::UniquenessValidator) }.size.zero? ? false : true
    end

  end
end