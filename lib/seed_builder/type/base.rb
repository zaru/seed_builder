module SeedBuilder
  module Type
    class Base
      def initialize key, model, core
        @key = key
        @model = model
        @core = core
      end

      private

      def association_keys model
        assoc_keys = []
        assocs = model.reflect_on_all_associations
        assocs.each do |assoc|
          if assoc.options[:polymorphic]
            assoc_keys << { key: assoc.foreign_key, klasses: @core.polymorphics[assoc.name].map{|poly| poly[:src]} }
          elsif assoc.is_a? ActiveRecord::Reflection::BelongsToReflection
            assoc_keys << { key: assoc.foreign_key, klasses: [assoc.klass] }
          end
        end
        assoc_keys
      end

      def polymorphic_keys model
        assoc_keys = []
        assocs = model.reflect_on_all_associations
        assocs.each do |assoc|
          if assoc.options[:polymorphic]
            assoc_keys << { key: assoc.foreign_type, klasses: @core.polymorphics[assoc.name].map{|poly| poly[:src]} }
          elsif assoc.is_a? ActiveRecord::Reflection::BelongsToReflection
            assoc_keys << { key: assoc.foreign_type, klasses: [assoc.klass] }
          end
        end
        assoc_keys
      end
    end
  end
end
