module SeedBuilder
  class Core

    # 各モデルで生成するレコード数
    # TODO: ここの値を外から調整できるようにする
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
    #
    # どのモデルも参照していないモデルからデータを生成する。
    # そうすることで参照しているモデルのデータ生成時には、参照先モデルのデータが存在する。
    # また、アソシエーションが何もないモデルは後から追加する。
    #
    # @return [Array<ActiveRecord::Base>]
    def ordered_entities
      entities = ordered_entities_from_relationships
      @domain.entities.delete_if{ |r| entities.map(&:name).include?(r.name) }
      entities.concat @domain.entities
    end

    # entities に親モデルから次々に要素をいれていく
    # @return [Array<Entity>]
    def ordered_entities_from_relationships
      rels = @domain.relationships.dup # 全リレーション
      entities = []
      while rels.count > 0
        rels.dup.each do |rel|
          src = rel[:src]
          if rels.select{ |r| r[:dst].name == src.name }.size.zero?
            entities << src
            rels.reject!{ |r| r[:src].name == src.name }
          end
        end
      end
      entities.uniq
    end

  end
end
