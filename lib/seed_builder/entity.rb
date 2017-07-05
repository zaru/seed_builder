# このモジュールを require するのは…rakeタスクの中にしたほうが良い気がする。
# そうしないとActiveRecordを常に拡張した状態になってしまう。

module SeedBuilder

  module EntityBase

    @@attributes = {}

    def create
      entity = new
      entity.attribute_collection.each do |attribute|
        attribute.build
      end

      # MEMO: ポリモーフィックは2つのフィールドでリレーションされるためここで上書き保存している
      polymorphic_columns.each do |column|
        belongs_to = polymorphic_belongs.sample
        entity[column[:type] + "_type"] = belongs_to.active_record.name
        entity[column[:foreign_key]] = belongs_to.active_record.all.sample.id
      end

      entity.save
    end

    # polymorphic関連を除いた指定モデルの外部キーリストを生成する
    def foreign_keys
      reflect_on_all_associations.select{|ref| !ref.options[:polymorphic] }.map{|ref|
        foreign_key = ref.foreign_key
        if "left_side_id" == ref.foreign_key
          foreign_key = ref.klass.reflect_on_all_associations.first.foreign_key
        end
        {foreign_key: foreign_key, klass: ref.klass }
      }
    end

    # TODO: 見直し対象
    def polymorphic_columns
      return @polymorphic_columns unless @polymorphic_columns.nil?
      @polymorphic_columns = []
      entities = Domain.new.entities
      polymorphic_associations.each do |ref|
        @polymorphic_columns << { type: ref.name.to_s, foreign_key: ref.foreign_key }
      end
      @polymorphic_columns
    end

    def polymorphic_associations
      reflect_on_all_associations.select{|ref| ref.options[:polymorphic] }
    end

    # ポリモーフィックの参照先（親）のリレーション情報配列を返す
    def polymorphic_belongs
      entities = Domain.new.entities
      entities.map{|e| e.reflect_on_all_associations}.flatten.select{|ref| ref.options[:as] && name == ref.class_name }
    end

  end

  # モデルオブジェクトのアトリビューション自身でデータをセットできるようにする
  module EntityObject

    def attribute_collection
      @attribute_collection ||= AttributeCollection.new(
        self.class.attribute_types.map do |key, active_model_type|
          Attribute.new(key, active_model_type, self.class, self)
        end
      )
    end

    # アトリビューション名で直接オブジェクトを参照できるようにする
    class AttributeCollection < Array
      def method_missing(method, *args)
        self.find{|attr| method.to_s == attr.key}
      end
    end
  end
end

ActiveRecord::Base.extend SeedBuilder::EntityBase
ActiveRecord::Base.include SeedBuilder::EntityObject
