module SeedBuilder
  module Validate
    class LengthValidator < SeedBuilder::Validate::Base

      def initialize maximum: 255, minimum: 0
        @maximum = maximum
        @minimum = minimum
      end

      # TODO: String型しか想定していないので他のも必要であれば対応する
      def call data:, entity:, key:
        return data.ljust @maximum, "a" if data.size < @minimum
        return data[0, @maximum - 1]    if data.size > @maximum
        data
      end

    end
  end
end
