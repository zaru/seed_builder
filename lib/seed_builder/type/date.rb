module SeedBuilder
  module Type
    class Date < Base
      def generate
        from = Date.parse "2000/01/01"
        to =  Date.parse "2017/12/31"
        Random.rand from..to
      end
    end
  end
end
