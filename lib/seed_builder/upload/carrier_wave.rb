module SeedBuilder
  module Upload
    class CarrierWave

      def initialize model, key
        @entity = model
        @key = key
      end

      def value
        File.open("files/test.#{ext}") do |file|
          @entity.send(@key.to_s + "=", file)
        end
      end

      private

      def ext
        if @entity.send(@key).extension_whitelist.nil?
          "jpg"
        else
          @entity.send(@key).extension_whitelist.sample
        end
      end

    end
  end
end