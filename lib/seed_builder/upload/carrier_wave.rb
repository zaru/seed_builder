module SeedBuilder
  module Upload
    class CarrierWave

      def initialize model, key
        @entity = model
        @key = key
      end

      def value
        path = File.expand_path(File.join(File.dirname(__FILE__), "../../../files/test.#{ext}"))
        File.open(path) do |file|
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