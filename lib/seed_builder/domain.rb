module SeedBuilder
  class Domain

    def initialize
      ActiveRecord::Base.clear_cache!
      # Rails.application.eager_load! #TODO: rakeタスクとかに移譲する
    end

    def entities
      models
    end

    def relationships
      @relationships ||= associations.select do |ref|
        # 親からの目線しかいらない（modelファイルが完全な前提）
        !ref.is_a?(ActiveRecord::Reflection::BelongsToReflection) &&
          # has_many through自体はいらない
          !ref.is_a?(ActiveRecord::Reflection::ThroughReflection)
      end.map do |ref|
        if ref.is_a? ActiveRecord::Reflection::HasAndBelongsToManyReflection
          relation_name = "#{ref.klass.name}::HABTM_#{ref.active_record.name.pluralize}"
          klass = Object.const_get relation_name
        else
          klass = ref.klass
        end
        { src: ref.original_model, dst: klass, association: ref.class }
      end
    end

    private

    # テーブルを所持していて、STI継承元ではないモデルのみを返す
    def models
      @models ||= ActiveRecord::Base.descendants.select{|model| available_model(model) } - superclasses
    end

    def associations
      @associations ||= models.map do |model|
        assocs = model.reflect_on_all_associations
        dup_assocs = []
        assocs.each do |assoc|
          dup_assoc = assoc.dup
          def dup_assoc.original_model= model
            @original_model = model
          end
          def dup_assoc.original_model
            @original_model
          end
          dup_assoc.original_model = model
          dup_assocs << dup_assoc
        end
        dup_assocs
      end.flatten
    end

    def available_model model
      if !model.abstract_class && model.table_exists?
        return true
      end
      false
    end

    def superclasses
      ActiveRecord::Base.descendants.map{|model| model.superclass }.uniq - [ActiveRecord::Base]
    end
  end
end
