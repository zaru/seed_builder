module SeedBuilder
  module Type
    class Base
      def initialize attr, entity, core
        @attr = attr
        @key = attr.key
        @entity = entity
        @model = entity.model
        @core = core
      end

      def value
        raise "Please implement this method."
      end

      def random_generate
        raise "Please implement this method."
      end

      private

      def association_keys model
        assoc_keys = []
        assocs = model.reflect_on_all_associations
        assocs.each do |assoc|
          if assoc.options[:polymorphic]
            assoc_keys << { key: assoc.foreign_key, klasses: @core.polymorphics[assoc.name].map{|poly| poly[:src]} }
          elsif assoc.is_a? ActiveRecord::Reflection::BelongsToReflection
            if "left_side_id" == assoc.foreign_key
              foreign_key = assoc.klass.reflect_on_all_associations.first.foreign_key
            else
              foreign_key = assoc.foreign_key
            end
            assoc_keys << { key: foreign_key, klasses: [assoc.klass] }
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
