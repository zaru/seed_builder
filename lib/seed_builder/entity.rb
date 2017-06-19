module SeedBuilder
  class Entity

    attr_reader :model

    def initialize model
      @model = model
    end

    def attrs
      @attrs ||= @model.attribute_types.map{|attr| Attribute.new(attr, self) }
    end

    # ポリモーフィックのtypeとforeign_keyのフィールド名組み合わせを作る
    def polymorphic_columns
      return @polymorphic_columns unless @polymorphic_columns.nil?
      @polymorphic_columns = []
      models = Domain.new.models
      polymorphic_associations.each do |ref|
        @polymorphic_columns << { type: ref.name.to_s, foreign_key: polymorphic_foreign_key(models, ref.name) }
      end
      @polymorphic_columns
    end

    # 外部キーと外部クラスノ組み合わせを作る
    def foreign_keys
      @model.reflect_on_all_associations.map{|ref| { foreign_key: ref.foreign_key, klass: ref.klass } }
    end

    private

    def polymorphic_foreign_key models, polymorphic_type
      models.map do |model|
        model.reflect_on_all_associations.each do |ref|
          if ref.options[:as] == polymorphic_type
            # 指定タイプの外部キーが見つかったらその時点で返す（他のを走査しても同じ為）
            return ref.foreign_key
          end
        end
      end
    end

    def polymorphic_associations
      @model.reflect_on_all_associations.select{|ref| ref.options[:polymorphic] }
    end

    def polymorphic? other_model, name
      other_model.reflect_on_all_associations.select{|ref| ref.options[:as] == name }.size > 0
    end

  end
end
