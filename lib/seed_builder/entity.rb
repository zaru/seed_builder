# TODO: このモジュールを require するのは…rakeタスクの中にしたほうが良い気がする。
# そうしないとActiveRecordを常に拡張した状態になってしまう。

module SeedBuilder

  module EntityBase

    @@attributes = {}

    # TODO: refactor name
    # 対象モデルのデータを生成して保存する
    def auto_create
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

      binding.pry
      entity.save
    end

    # foreign keys only belongs_to association
    # and excluding polymorphic
    #
    #
    # [{
    #   foreign_key: "key name",
    #   klass: Klass
    # }]
    #
    # @return [Array<Hash>]
    def foreign_keys
      reflect_on_all_associations.select{|ref| foreign_association(ref) }.map{|ref|
        foreign_key = ref.foreign_key
        if "left_side_id" == ref.foreign_key
          foreign_key = ref.klass.reflect_on_all_associations.first.foreign_key
        end
        {foreign_key: foreign_key, klass: ref.klass }
      }
    end

    # foreign keys and polymorphic type of polymorphic
    #
    # [{
    #   foreign_key: "key name",
    #   type: "polymorphic type"
    # }]
    #
    # @return [Array<Hash>]
    def polymorphic_columns
      return @polymorphic_columns unless @polymorphic_columns.nil?
      @polymorphic_columns = []
      polymorphic_associations.each do |ref|
        @polymorphic_columns << { type: ref.name.to_s, foreign_key: ref.foreign_key }
      end
      @polymorphic_columns
    end


    private

    # Returns the polymorphic association to itself
    # from the relation information of the reference source
    #
    # @return [Array<Object>]
    def polymorphic_belongs
      entities = Domain.new.entities
      entities.map{|e| e.reflect_on_all_associations}.flatten.select{|ref| ref.options[:as] && name == ref.class_name }
    end

    # polymorphic associations
    #
    # @return [Array<Object>]
    def polymorphic_associations
      reflect_on_all_associations.select{|ref| ref.options[:polymorphic] }
    end

    # only belongs_to association and excluding polymorphic
    #
    # @param [Object] ref
    # @return [Boolean]
    def foreign_association ref
      return false if ref.options[:polymorphic]
      return true if ref.is_a? ActiveRecord::Reflection::BelongsToReflection
      false
    end

  end

  module EntityObject

    # Return SeedBuilder::Attribute objects
    #
    # Usage:
    #   HogeModel.new.attribute_collection
    #
    # @return [Array<SeedBuilder::Attribute>]
    def attribute_collection
      @attribute_collection ||= AttributeCollection.new(
        self.class.attribute_types.map do |key, active_model_type|
          Attribute.new(key, active_model_type, self.class, self)
        end
      )
    end

    # Call SeedBuilder::Attribute object with field name
    #
    # Usage:
    #   HogeModel.new.attribute_collection.field_name
    #
    class AttributeCollection < Array
      def method_missing(method, *args)
        self.find{|attr| method.to_s == attr.key}
      end
    end

    def valid_attribute?(attribute_name)
      self.valid?
      self.errors[attribute_name].blank?
    end
  end
end

ActiveRecord::Base.extend SeedBuilder::EntityBase
ActiveRecord::Base.include SeedBuilder::EntityObject
