# このモジュールを require するのは…rakeタスクの中にしたほうが良い気がする。
# そうしないとActiveRecordを常に拡張した状態になってしまう。

module SeedBuilder

  module EntityBase

    @@attributes = {}

    # 対象モデルのデータを生成して保存する
    def create
      entity = new
      entity.attribute_collection.each do |attribute|
        attribute.build
      end

      # ポリモーフィックは2つのフィールドでリレーションされるためここで上書き保存している
      #
      # 例
      #   Messageモデルがポリモーフィックの場合
      #     - messagable_type: <リレーション先モデル名>
      #     - messagable_id: <リレーション先モデルID>
      #   上記2つの組み合わせによってリレーション先が決まる。
      #
      # TODO: このロジックをメソッドに抽出したい
      polymorphic_columns.each do |column|
        belongs_to = polymorphic_belongs.sample
        if belongs_to
          entity[column[:type] + "_type"] = belongs_to.active_record.name
          entity[column[:foreign_key]]    = belongs_to.active_record.all.sample.id
        else
          entity[column[:type] + "_type"] = nil
          entity[column[:foreign_key]]    = nil
        end
      end

      entity.save
    end

    # polymorphic関連を除いた指定モデルの外部キーリストを生成する
    #
    # {
    #   foreign_key: 外部キー名
    #   klass: 外部キークラス
    # }
    #
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
    # polymorphicの外部キーとモデルリストを返す
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
    # ポリモーフィックモデル自身から参照先を割り出すことができないので、
    # 全モデルから参照しているかどうかを取りに行く（ちょっと非効率）。
    def polymorphic_belongs
      entities = Domain.new.entities
      entities.map{|e| e.reflect_on_all_associations}.flatten.select{|ref| ref.options[:as] && name == ref.class_name }
    end

  end

  # モデルオブジェクトのアトリビューション自身でデータをセットできるようにする
  module EntityObject

    # Usage:
    #   HogeModel.new.attribute_collection
    def attribute_collection
      @attribute_collection ||= AttributeCollection.new(
        self.class.attribute_types.map do |key, active_model_type|
          Attribute.new(key, active_model_type, self.class, self)
        end
      )
    end

    # アトリビューション名で直接オブジェクトを参照できるようにする
    # Usage:
    #   HogeModel.new.attribute_collection.key_name
    class AttributeCollection < Array
      def method_missing(method, *args)
        self.find{|attr| method.to_s == attr.key}
      end
    end
  end
end

ActiveRecord::Base.extend SeedBuilder::EntityBase
ActiveRecord::Base.include SeedBuilder::EntityObject
