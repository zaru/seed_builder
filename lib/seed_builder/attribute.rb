module SeedBuilder
  class Attribute

    attr_reader :key, :type, :validates, :entity

    def initialize key, active_model_type, entity, model_object
      @key          = key
      @entity       = entity
      @model_object = model_object
      @type_name    = active_model_type.type.to_s.capitalize
    end

    def build
      if auto_generate?
        return @model_object.send "#{@key}=", nil
      end

      if sti_type?
        return @model_object.send "#{@key}=", @entity.name
      end

      if foreign_key?
        # MEMO: すでに親クラスにデータがぞんざいしている前提なので単体だとnilが入る
        # もしかしたら後からの救済メソッドを作っても良いのかもしれない。
        return @model_object.send "#{@key}=", foreign_klass.all.sample.id
      end

      if carrier_wave?
        return SeedBuilder::Upload::CarrierWave.new(@model_object, @key).value
      end

      # Paperclip has multiple columns.
      # However, file insertion is a virtual column.
      # Therefore, it is not inserted here.
      # Do it in Entity.auto_create.
      if paperclip?
        return
      end

      if enumerize?
        return @model_object.send "#{@key}=", @entity.send(@key).send(:values).sample
      end

      # NOTE: いったん、わかりやすさのため tmp var 使う
      data = ValidData.new(
                  type_name:    @type_name,
                  model_object: @model_object,
                  key:          @key).generate
      @model_object.send "#{@key}=", data
    end

    private

    # CarrierWaveかどうか判定
    # 一度モデルをインスタンスにしないと判定できない
    def carrier_wave?
      return false unless defined? CarrierWave
      @entity.new.send(@key).is_a? CarrierWave::Uploader::Base
    end

    def paperclip?
      return false unless defined? Paperclip
      return false unless @entity.respond_to? :attachment_definitions
      @entity.attachment_definitions.each do |attach_key, option|
        regex = /\A#{attach_key}_(file_name|content_type|file_size|updated_at)\z/
        return true if @key =~ regex
      end
      false
    end

    # 外部キー判定
    def foreign_key?
      # ポリモーフィックの外部キーはこの時点でリレーション先のモデルを確定できないので、普通のフィールドとして扱う
      return false if polymorphic_foreign_key?
      return true if @entity.foreign_keys.find{|f| @key == f[:foreign_key] }
      return true if "left_side_id" == @key
      false
    end

    # enumerize field
    def enumerize?
      return false unless defined? Enumerize
      return false unless @entity.respond_to? :enumerized_attributes
      @entity.enumerized_attributes.attributes.keys.include? @key
    end

    # 外部クラス
    def foreign_klass
      return nil if polymorphic_foreign_key?

      if foreign = @entity.foreign_keys.find{|f| @key == f[:foreign_key] }
        return foreign[:klass]
      end

      # TODO: left_side_id の対応
    end

    # サロゲートキー判定
    def auto_generate?
      # TODO: Rails規約どおりの場合のみ想定しているのでカスタムに対応する
      "id" == @key
    end

    # STI用のTypeフィールドかどうかの判定
    def sti_type?
      "type" == @key && @entity.superclass != ActiveRecord::Base
    end

    # ポリモーフィックで使われている外部キー判定
    def polymorphic_foreign_key?
      @entity.polymorphic_columns.find{|c| @key == c[:foreign_key] } ? true : false
    end
  end
end
