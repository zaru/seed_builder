module SeedBuilder
  class Domain

    def initialize
      ActiveRecord::Base.clear_cache!
      # Rails.application.eager_load! #TODO: rakeタスクとかに移譲する
    end

    # モデルの一覧を返す
    #
    # @return [Array<ActiveRecord::Base>]
    def entities
      models
    end

    # リレーションの関係を返す
    #
    # {
    #   src: <参照先のモデルクラス>
    #   dst: <参照元のモデルクラス>
    #   association: <リレーションクラス>
    # }
    # 
    # @return [Array<Hash>]
    def relationships
      @relationships ||= associations.select do |ref|
        # 親からの目線しかいらない（modelファイルが完全な前提）
        !ref.is_a?(ActiveRecord::Reflection::BelongsToReflection) &&
          # has_many through自体はいらない
          !ref.is_a?(ActiveRecord::Reflection::ThroughReflection)
      end.map do |ref|
        if ref.is_a? ActiveRecord::Reflection::HasAndBelongsToManyReflection
          # has_and_belongs_to_manyの場合、1つの中間モデルが2つのモデルになってしまうので、片方に寄せる
          first, last = ref.klass.name > ref.active_record.name.pluralize ?
            [ref.klass.name, ref.active_record.name.pluralize] : [ref.active_record.name.pluralize, ref.klass.name]
          relation_name = "#{first.singularize}::HABTM_#{last.pluralize}"
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
      @models ||= ActiveRecord::Base.descendants.select{|model| available_model(model) }.map{|model| integrate_habtm_name(model) }.uniq - superclasses
    end

    # 全てのモデルのアソシエーションを返す
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

    # 有効なモデルかどうかの判定
    #
    # - abstract_classは除外
    # - 実テーブルがないものは除外
    #
    def available_model model
      if !model.abstract_class && model.table_exists?
        return true
      end
      false
    end

    # 継承されているスーパークラス一覧
    def superclasses
      ActiveRecord::Base.descendants.map{|model| model.superclass }.uniq - [ActiveRecord::Base]
    end

    # HABTMの中間モデルが複数になってしまうので片方に寄せる
    #
    # 例
    #   RoleとAccount2つのHABTMの場合、以下の2つの中間モデルができあがる。
    #     - Role::HABTM_Accounts
    #     - Account::HABTM_Roles
    #   これを片方のモデルに寄せることでシンプルにする。
    #   寄せルールは、2つのモデル名を英数字順で並び替えて上のほうが先になるモデル名とする。
    #
    def integrate_habtm_name model
      return model unless names = model.to_s.match(/\A(.+)::HABTM_(.+)\z/)
      # TODO: リファクタ候補コード
      # names.delete_at 0
      # first, last = names.sort

      first, last = names[1] < names[2] ? [names[1], names[2]] : [names[2], names[1]]
      Object.const_get "#{first.singularize}::HABTM_#{last.pluralize}"
    end
  end
end
