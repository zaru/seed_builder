module SeedBuilder
  module Validate
    class LengthValidator < SeedBuilder::Validate::Base

      def initialize maximum: 255, minimum: 0
        @maximum = maximum
        @minimum = minimum
      end

      # NOTE: data のタイプは問わない
      def call data:, entity:

        # NOTE: data.ljust や data[x, y] は Integer には効かないため。
        str = data.to_s

        return str.ljust(@maximum), "a" if data.size < @minimum
        return str[0, @maximum]         if data.size > @maximum
        data
      end

    end
  end
end
