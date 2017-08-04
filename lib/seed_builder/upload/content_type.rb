module SeedBuilder
  module Upload
    module ContentType

      # Return ext name
      #
      # @param [String] content_type
      # @return [String]
      def match_content_type content_type
        if content_type =~ /jpe?g/
          "jpg"
        elsif content_type =~ /png/
          "png"
        elsif content_type =~ /gif/
          "gif"
        elsif content_type =~ /pdf/
          "pdf"
        else
          "jpg"
        end
      end

    end
  end
end
