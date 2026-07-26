require "liquid"

module Jekyll
  module LinkCard
    class Tag < Liquid::Tag
      SYNTAX = /\A\s*(\S+)\s*\z/

      def initialize(_tag_name, markup, _parse_context)
        super
        match = markup.match(SYNTAX)
        raise SyntaxError, "Syntax: {% link_card URL %}" unless match

        @url = match[1]
      end

      def render(context)
        site = context.registers[:site]
        mode = site.config.dig("link_card", "mode") || "preprocess"

        og = resolve(site, mode)
        return "" unless og

        build_html(og)
      rescue StandardError
        ""
      end

      private

      def resolve(site, mode)
        if mode == "hybrid"
          hybrid_data(site)
        else
          preprocess_data
        end
      end

      def preprocess_data
        cached = Cache.read(@url)
        return cached if cached

        data = OgFetcher.fetch(@url)
        Cache.write(@url, data) if data
        data
      end

      def hybrid_data(site)
        cards = site.data&.dig("link-cards") || {}
        cards[@url]
      end

      def build_html(og)
        title = escape(og["og:title"] || @url)
        description = escape(og["og:description"] || "")
        image = og["og:image"]
        url = escape(og["url"] || @url)

        <<~HTML
          <div class="link-card">
            #{image_tag(image)}
            <div class="link-card-content">
              <a href="#{url}" class="link-card-title" target="_blank" rel="noopener noreferrer">#{title}</a>
              #{description_tag(description)}
            </div>
          </div>
        HTML
      end

      def image_tag(src)
        return "" unless src

        %(<img src="#{escape(src)}" alt="" class="link-card-image" loading="lazy" />)
      end

      def description_tag(text)
        return "" if text.empty?

        %(<p class="link-card-description">#{text}</p>)
      end

      def escape(str)
        str.to_s
          .gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
          .gsub('"', "&quot;")
      end
    end
  end
end

Liquid::Template.register_tag("link_card", Jekyll::LinkCard::Tag)
