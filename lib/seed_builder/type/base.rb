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
    end
  end
end
