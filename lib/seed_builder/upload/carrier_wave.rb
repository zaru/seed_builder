module SeedBuilder
  module Upload
    class CarrierWave

      include SeedBuilder::Upload::ContentType

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
        unless @entity.send(@key).extension_whitelist.nil?
          return @entity.send(@key).extension_whitelist.sample
        end

        unless content_type_whitelist.nil?
          return match_content_type content_type_whitelist
        end

        "jpg"
      end

      def content_type_whitelist
        @entity.send(@key).content_type_whitelist.to_s
      end

    end
  end
end