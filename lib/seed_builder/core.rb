module SeedBuilder
  class Core
    attr_reader :relationships, :models

    def initialize
      domain = Domain.new
      @relationships = domain.relationships
      @models = domain.models
    end

    def execute
      while @relationships.size > 0 do
        loop_pickup
      end

      left_model_generate
      nil
    end

    private

    def loop_pickup
      @relationships.each_with_index do |rel, i|
        next unless @relationships.select{|r| rel[:src].name == r[:dst].name}.size.zero?
        @relationships.delete_if{|r| rel[:src].name == r[:src].name}
        @models.delete_if{|r| rel[:src].name == r.name}

        20.times{generate rel[:src]}
      end
    end

    def left_model_generate
      @models.each do |model|
        20.times{ generate model }
      end
    end

    def generate model
      data = model.new
      attrs = model.attribute_types
      attrs.each do |key, attr|
        next if "id" == key
        data[key.to_sym] = Object.const_get("SeedBuilder::Type::#{attr.type.to_s.capitalize}").new(key, model).value
      end
      data.save
    end
  end
end
