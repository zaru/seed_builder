module SeedBuilder
  module Upload
    class CarrierWave

      def initialize model, key
        @entity = model
        @key = key
      end

      def value
        ext = @entity.send(@key).extension_whitelist.first
        File.open("files/test.#{ext}") do |file|
          @entity.send(@key.to_s + "=", file)
        end
      end

    end
  end
end