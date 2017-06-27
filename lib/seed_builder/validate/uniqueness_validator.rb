module SeedBuilder
  module Validate
    class UniquenessValidator < SeedBuilder::Validate::Base

      def initialize case_sensitive: true
        @case_sensitive = case_sensitive
      end

      def call data:, entity:, key:
        @data   = data
        @entity = entity
        @key    = key
        binding.pry
        return unique
      end

      private

      def unique
        if @entity.send(:"find_by_#{@key}", @data).nil?
          return @data
        end
        @data.next
        unique
      end

    end
  end
end
