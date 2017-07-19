# Generate Model and Table DSL
#
# You can define model classes and generate physical tables
# at the same time.
#
# This DSL is intended to simplify the test code and does not
# assume the production environment.
#
# Usage:
#
#   ModelGenerator::create_model(:books) do
#     string :name, null: false
#     integer :number, unique: true
#   end
#
#
#   Associations example.
#
#   ModelGenerator::create_model(:movies) do
#     string :name, null: false
#
#     has_many :messages
#   end
#
#
#   Polymorphic model example.
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
#
#   STI model example.
#
#   ModelGenerator::create_model(:books) do
#     string :type, null: false
#   end
#
#   ModelGenerator::create_model(:game_books, :books) do
#   end
#
#   ModelGenerator::create_model(:music_books, :books) do
#   end
#
#
#   HABTM model example.
#
#   ModelGenerator::create_model(:books) do
#     has_and_belongs_to_many :users
#   end
#   ModelGenerator::create_model(:users) do
#     has_and_belongs_to_many :books
#   end
#   ModelGenerator::create_table(:books_users) do
#     references :book, index: true, null: false
#     references :user, index: true, null: false
#   end
#
#
#   Validation example.
#
#   ModelGenerator::create_model(:users) do
#     string :name
#     validates :name, presence: true
#   end
#
#
#   Other method example.
#
#   class IconUploader < CarrierWave::Uploader::Base
#     storage :file
#   end
#   ModelGenerator::create_model(:users) do
#     string :icon, null: false
#     mount_uploader :avatar, IconUploader
#   end
module ModelGenerator

  # @param [Symbol] model_name
  # @param [Symbol] inherit_model_name
  # @param [Object] block
  def self.create_model model_name, inherit_model_name = nil, &block
    model = Model.new
    model.name = model_name
    model.inherit_name = inherit_model_name
    model.instance_eval &block
    model.generate_all
  end

  # @param [Symbol] table_name
  # @param [Object] block
  def self.create_table table_name, &block
    model = Model.new
    model.name = table_name
    model.instance_eval &block
    model.generate_table
  end

  # All reset to current Model and Table
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

    # ref: voormedia/rails-erd
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
      @validations = []
      @commands = []
    end

    def class_name
      @class_name ||= @name.to_s.classify
    end

    def name= name
      @name = name
    end

    def inherit_name= name
      @inherit_name = name
    end

    def validates *attr
      @validations << attr
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
      if @inherit_name
        Object.const_set class_name, Class.new(Object.const_get(@inherit_name.to_s.classify))
      else
        Object.const_set class_name, Class.new(ActiveRecord::Base)
      end
      @associations.each do |assoc|
        if assoc[:options].size.zero?
          Object.const_get(class_name).send assoc[:type], assoc[:model]
        else
          Object.const_get(class_name).send assoc[:type], assoc[:model], *assoc[:options]
        end
      end
      @validations.each do |validate|
        Object.const_get(class_name).send :validates, *validate
      end
      @commands.each do |cmd|
        Object.const_get(class_name).send cmd[0], *cmd[1]
      end
    end

    def method_missing name, *args
      @commands << [name, args]
    end
  end
end