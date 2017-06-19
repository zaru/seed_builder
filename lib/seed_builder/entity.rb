module SeedBuilder
  class Entity

    attr_reader :model

    def initialize model
      @model = model
    end

    def attrs
      @attrs ||= @model.attribute_types.map{|attr| Attribute.new(attr, @model) }
    end

  end
end
