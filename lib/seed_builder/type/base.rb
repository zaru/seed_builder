module SeedBuilder
  module Type
    class Base
      def initialize key, model
        @key = key
        @model = model
      end

      private

      def association_keys model
        assoc_keys = []
        assocs = model.reflect_on_all_associations
        assocs.each do |assoc|
          if assoc.is_a? ActiveRecord::Reflection::BelongsToReflection
            assoc_keys << { key: assoc.foreign_key, klass: assoc.klass }
          end
        end
        assoc_keys
      end
    end
  end
end
