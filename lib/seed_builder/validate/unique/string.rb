module SeedBuilder
  module Validate
    module Unique
      class String < SeedBuilder::Validate::Base
        class << self
          def call data, entity
            "#{data} is unique"
          end
        end
      end
    end
  end
end