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
        next if entities.include? rel[:src]
        next unless @domain.relationships.select{|r| rel[:src].name == r[:dst].name}.size.zero?
        entities << rel[:src]
        @domain.entities.delete_if{|r| rel[:src].name == r.name}
      end
      entities.concat @domain.entities
    end

  end
end
