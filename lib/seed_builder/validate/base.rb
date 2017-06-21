module SeedBuilder
  module Validate
    class Base
      class << self
        def call data, entity
          raise "Please implement this method"
        end
      end
    end
  end
end