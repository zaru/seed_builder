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
        unless @entity.send(@key).extension_whitelist.nil?
          return @entity.send(@key).extension_whitelist.sample
        end

        unless content_type_whitelist.nil?
          return content_type
        end

        "jpg"
      end

      def content_type_whitelist
        @entity.send(@key).content_type_whitelist.to_s
      end

      def content_type
        if content_type_whitelist =~ /jpe?g/
          "jpg"
        elsif content_type_whitelist =~ /png/
          "png"
        elsif content_type_whitelist =~ /gif/
          "gif"
        elsif content_type_whitelist =~ /pdf/
          "pdf"
        else
          "jpg"
        end
      end

    end
  end
end