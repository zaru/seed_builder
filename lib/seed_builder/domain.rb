module SeedBuilder
  class Domain

    def initialize
      ActiveRecord::Base.clear_cache!
      # Rails.application.eager_load! #TODO: rakeタスクとかに移譲する
    end

    def models
      @models ||= ActiveRecord::Base.descendants.select{|model| !model.abstract_class?}
    end

    def associations
      @associations ||= models.collect(&:reflect_on_all_associations).flatten
    end

    def relationships
      @relationships ||= associations.select do |ref|
        !ref.is_a? ActiveRecord::Reflection::BelongsToReflection # 親からの目線しかいらない（modelファイルが完全な前提）
      end.map do |ref|
        { src: ref.active_record, dst: ref.klass, association: ref.class }
      end
    end

    def polymorphics
      @polymorphics ||= associations.select do |assoc|
        assoc.options[:as]
      end.map do |assoc|
        {
          as: assoc.options[:as], 
          klass: assoc.class_name, 
          src: assoc.active_record
        }
      end.group_by do |h|
        h[:as]
      end
    end

  end
end
