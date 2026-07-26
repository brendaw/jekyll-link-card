# frozen_string_literal: true

require "net/http"
require "uri"
require "nokogiri"

module Jekyll
  module LinkCard
    module OgFetcher
      OG_TAGS = %w[og:title og:description og:image].freeze

      def self.fetch(url)
        uri = URI.parse(url)
        response = perform_request(uri)
        return nil unless response.is_a?(Net::HTTPSuccess)

        doc = Nokogiri::HTML(response.body)
        extract_og(doc, uri)
      rescue StandardError
        nil
      end

      def self.perform_request(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        http.open_timeout = 5
        http.read_timeout = 5

        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = "JekyllLinkCard/0.1.0"

        http.request(request)
      end

      def self.extract_og(doc, base_uri)
        meta = {}

        OG_TAGS.each do |tag|
          node = doc.at_css("meta[property='#{tag}'], meta[name='#{tag}']")
          content = node&.attr("content")
          next if content.nil? || content.empty?

          meta[tag] = resolve_url(content, base_uri) if tag == "og:image"
          meta[tag] = content unless tag == "og:image"
        end

        return nil if meta.empty?

        meta["url"] = base_uri.to_s
        meta
      end

      def self.resolve_url(src, base)
        URI.join(base, src).to_s
      rescue URI::InvalidURIError
        src
      end
    end
  end
end
