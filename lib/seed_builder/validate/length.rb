module SeedBuilder
  module Validate
    class Length < SeedBuilder::Validate::Base
      class << self
        def call data, entity
          # TODO: String型しか想定していないので他のも必要であれば対応する
          return data.ljust @maximum, "a" if data.size < @minimum
          return data[0, @maximum - 1] if data.size > @maximum
          data
        end
      end
    end
  end
end
