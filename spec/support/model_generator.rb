module ModelGenerator
  def self.create_model model_name, &block
    model = Model.new
    model.name = model_name
    model.instance_eval &block
    model.generate
  end

  # 定義したモデルクラスやテーブル構造をすべてリセットする
  #
  # Usage:
  #  ModelGenerator::Reset.new.all
  #
  class Reset

    def all
      if defined? ActiveRecord
        ActiveRecord::Base.descendants.each do |model|
          next if model.name == "ActiveRecord::InternalMetadata"
          model.reset_column_information if Object.const_defined?(model.name) # fixed
          remove_fully_qualified_constant(model.name)
        end
        tables_and_views.each do |table|
          ActiveRecord::Base.connection.drop_table table
        end
        ActiveRecord::Base.direct_descendants.clear
        ActiveSupport::Dependencies::Reference.clear!
        ActiveRecord::Base.clear_cache!
      end
    end

    private

    # voormedia/rails-erd より拝借
    def name_to_object_symbol_pairs(name)
      parts = name.to_s.split('::')

      return [] if parts.first == '' || parts.count == 0

      parts[1..-1].inject([[Object, parts.first.to_sym]]) do |pairs,string|
        last_parent, last_child = pairs.last

        break pairs unless last_parent.const_defined?(last_child)

        next_parent = last_parent.const_get(last_child)
        next_child = string.to_sym
        pairs << [next_parent, next_child]
      end
    end

    def remove_fully_qualified_constant(name)
      pairs = name_to_object_symbol_pairs(name)
      pairs.reverse.each do |parent, child|
        parent.send(:remove_const,child) if parent.const_defined?(child)
      end
    end

    def tables_and_views
      if ActiveRecord::VERSION::MAJOR >= 5
        ActiveRecord::Base.connection.data_sources
      else
        ActiveRecord::Base.connection.tables
      end
    end

  end


  # [WIP] モデルとテーブルを動的に生成するDSL
  # 細かいオプションに対応するのが面倒なので、もっと簡素なDSL構造にする予定
  #
  # Usage:
  #   ModelGenerator::create_model(:users) do |model|
  #     model.columns :string, :name, null: false
  #     model.has_many :articles
  #   end
  #
  class Model
    def initialize
      @columns = []
      @associations = []
    end

    def name= name
      @name = name
    end

    def columns *attr
      @columns << attr
    end

    def belongs_to model
      @associations << { type: :belongs_to, model: model }
    end

    def has_many model
      @associations << { type: :has_many, model: model }
    end

    def has_one model
      @associations << { type: :has_one, model: model }
    end

    def has_and_belongs_to_many model
      @associations << { type: :has_and_belongs_to_many, model: model }
    end

    def generate
      name = @name
      columns = @columns
      ActiveRecord::Schema.instance_eval do
        suppress_messages do
          create_table(name) do |t|
            columns.each do |column|
              attr_type, attr_name, *options = column
              t.send attr_type, attr_name, *options
            end
            t.timestamps
          end
        end
      end
      class_name = name.to_s.classify
      Object.const_set class_name, Class.new(ActiveRecord::Base)
      @associations.each do |assoc|
        Object.const_get(class_name).send assoc[:type], assoc[:model]
      end
    end
  end
end