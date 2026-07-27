# frozen_string_literal: true

require "liquid"

module Jekyll
  module LinkCard
    class Tag < Liquid::Tag
      SYNTAX = /\A\s*(\S+)(?:\s+(truncation:\d+|display:(?:inline|block)))*\s*\z/.freeze
      PARAM_RE = /(truncation:(\d+)|display:(inline|block))/.freeze

      DEFAULT_CSS = <<~CSS
        .link-card{display:flex;border:1px solid #e1e4e8;border-radius:6px;overflow:hidden;width:100%;font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Helvetica,Arial,sans-serif;margin:1em 0}.link-card-image{position:relative;width:200px;min-height:150px;flex-shrink:0;border-right:1px solid #e1e4e8}.link-card-image img{position:absolute;top:0;left:0;width:100%;height:100%;object-fit:cover}.link-card-content{padding:12px 16px;display:flex;flex-direction:column;justify-content:center;min-width:0}.link-card-title{font-size:16px;font-weight:600;color:#0366d6;text-decoration:none;margin:0 0 4px;line-height:1.3}.link-card-title:hover{text-decoration:underline}.link-card-description{font-size:14px;color:#586069;margin:0;line-height:1.5;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}.link-card-block{flex-direction:column}.link-card-block .link-card-image{width:100%;min-height:200px;border-right:none;border-bottom:1px solid #e1e4e8}
      CSS

      @style_output = false

      class << self
        attr_accessor :style_output
      end

      def initialize(_tag_name, markup, _parse_context)
        super
        match = markup.match(SYNTAX)
        raise SyntaxError, "Syntax: {% link_card URL [truncation:N] [display:inline|block] %}" unless match

        @url = match[1]
        @truncation = nil
        @display = nil

        markup.scan(PARAM_RE) do
          if ::Regexp.last_match(1).start_with?("truncation:")
            @truncation = ::Regexp.last_match(2).to_i
          elsif ::Regexp.last_match(1).start_with?("display:")
            @display = ::Regexp.last_match(3)
          end
        end
      end

      def render(context)
        site = context.registers[:site]
        mode = site.config.dig("link_card", "mode") || "preprocess"
        global_truncation = site.config.dig("link_card", "truncation")
        global_display = site.config.dig("link_card", "display")

        og = resolve(site, mode)
        return "" unless og

        truncation = @truncation || global_truncation
        display = @display || global_display || "inline"
        build_html(og, truncation.to_i, display)
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

      def build_html(data, truncation = 0, display = "inline")
        title = escape(data["og:title"] || @url)
        description = escape(data["og:description"] || "")
        image = data["og:image"]
        url = escape(data["url"] || @url)

        if display == "block"
          block_html(title, description, image, url, truncation)
        else
          inline_html(title, description, image, url, truncation)
        end
      end

      def inline_html(title, description, image, url, truncation)
        "#{style_tag}
#{<<~HTML}"
  <div class="link-card">
    #{image_tag(image)}
    <div class="link-card-content">
      <a href="#{url}" class="link-card-title" target="_blank" rel="noopener noreferrer">#{title}</a>
      #{description_tag(description, truncation)}
    </div>
  </div>
HTML
      end

      def block_html(title, description, image, url, truncation)
        "#{style_tag}
#{<<~HTML}"
  <div class="link-card link-card-block">
    #{image_tag(image)}
    <div class="link-card-content">
      <a href="#{url}" class="link-card-title" target="_blank" rel="noopener noreferrer">#{title}</a>
      #{description_tag(description, truncation)}
    </div>
  </div>
HTML
      end

      def style_tag
        return "" if self.class.style_output

        self.class.style_output = true
        "<style>#{DEFAULT_CSS}</style>"
      end

      def image_tag(src)
        return "" unless src

        %(<img src="#{escape(src)}" alt="" class="link-card-image" loading="lazy" />)
      end

      def description_tag(text, truncation = 0)
        return "" if text.empty?

        style = truncation.positive? ? " style=\"-webkit-line-clamp:#{truncation}\"" : ""
        %(<p class="link-card-description"#{style}>#{text}</p>)
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
