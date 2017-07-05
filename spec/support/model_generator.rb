module ModelGenerator
  def self.create_model model_name, &block
    model = Model.new
    model.name = model_name
    model.instance_eval &block
    model.generate_all
  end

  def self.create_table table_name, &block
    model = Model.new
    model.name = table_name
    model.instance_eval &block
    model.generate_table
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


  # モデルとテーブルを動的に生成するDSL
  #
  # Usage:
  #
  #   ModelGenerator::create_model(:books) do
  #     string :name, null: false
  #   end
  #
  #   ModelGenerator::create_model(:movies) do
  #     string :name, null: false
  #
  #     has_many :messages, as: :messagable
  #   end
  #
  #   ModelGenerator::create_model(:reviews) do
  #     string :comment, null: false
  #     references :messagable, polymorphic: true
  #
  #     belongs_to :messagable, polymorphic: true
  #   end
  #
  class Model

    %w(string text integer float decimal datetime timestamp time date binary boolean references).each do |type|
      define_method type do |*attr|
        @columns << ([type].concat attr)
      end
    end

    %w(belongs_to has_many has_one has_and_belongs_to_many).each do |assoc|
      define_method assoc do |model, *options|
        @associations << { type: assoc.to_sym, model: model, options: options }
      end
    end

    def initialize
      @columns = []
      @associations = []
    end

    def name= name
      @name = name
    end

    def generate_all
      generate_table
      generate_model
    end

    def generate_table
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
    end

    def generate_model
      class_name = @name.to_s.classify
      Object.const_set class_name, Class.new(ActiveRecord::Base)
      @associations.each do |assoc|
        if assoc[:options].size.zero?
          Object.const_get(class_name).send assoc[:type], assoc[:model]
        else
          Object.const_get(class_name).send assoc[:type], assoc[:model], *assoc[:options]
        end
      end
    end
  end
end