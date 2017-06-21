module SeedBuilder
  class Core

    BUILD_NUM = 1

    def initialize
      @domain = Domain.new
    end

    def processing
      ordered_entities.each do |entity|
        BUILD_NUM.times{ entity.create }
      end
    end

    private

    # 処理すべき順番にEntityを並び替える
    def ordered_entities
      entities = []
      @domain.relationships.each do |rel|
        next unless @domain.relationships.select{|r| rel[:src].name == r[:dst].name}.size.zero?
        @domain.relationships.delete_if{|r| rel[:src].name == r[:src].name}
        @domain.entities.delete_if{|r| rel[:src].name == r.name}
        entities << rel[:src]
      end
      entities.concat @domain.entities
    end

  end
end
