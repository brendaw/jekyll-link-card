module Jekyll
  module LinkCard
    class Tag
      def initialize(url)
        @url = url
      end

      def render(_context)
        "link_card stub for #{@url}"
      end
    end
  end
end
