module SeedBuilder
  module Upload
    class CarrierWave

      def initialize model, key
        @model = model
        @key = key
      end

      def value
        ext = @model.send(@key).extension_whitelist.first
        File.open("files/test.#{ext}") do |file|
          @model.send(@key.to_s + "=", file)
        end
      end

    end
  end
end