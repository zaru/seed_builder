module SeedBuilder
  class Core
    attr_reader :relationships, :models

    def initialize
      domain = Domain.new
      @relationships = domain.relationships
      @models = domain.models
    end

    def build
      while @relationships.size > 0 do
        loop_pickup
      end
    end

    private

    def loop_pickup
      @relationships.each_with_index do |rel, i|
        next unless @relationships.select{|r| rel[:src].name == r[:dst].name}.size.zero?
        @relationships.delete_if{|r| rel[:src].name == r[:src].name}
        @models.delete_if{|r| rel[:src].name == r.name}
      end
    end
  end
end
