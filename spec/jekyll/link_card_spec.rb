# frozen_string_literal: true

require "spec_helper"

# Stub Liquid before loading tag
module Liquid
  class Tag
    def self.new(*)
      super
    end

    def initialize(_tag_name, _markup, _parse_context); end

    def render(_context)
      ""
    end
  end

  class Template
    def self.register_tag(_name, _klass); end
  end
end

require "jekyll-link-card"

RSpec.describe "Jekyll::LinkCard integration" do
  let(:cache_dir) { "tmp/cache/link-card-test" }

  before do
    Jekyll::LinkCard::Tag.style_output = false
    stub_const("Jekyll::LinkCard::Cache::CACHE_DIR", cache_dir)
    FileUtils.rm_rf(cache_dir)
  end

  after do
    FileUtils.rm_rf(cache_dir)
  end

  describe "full preprocess flow" do
    it "fetches, caches, and renders HTML" do
      html = <<~HTML
        <html><head>
          <meta property="og:title" content="GitHub" />
          <meta property="og:description" content="Where the world builds software" />
          <meta property="og:image" content="https://github.com/favicon.png" />
        </head></html>
      HTML

      stub_request(:get, "https://github.com")
        .to_return(status: 200, body: html)

      tag = Jekyll::LinkCard::Tag.new("link_card", " https://github.com ", nil)
      result = tag.send(:preprocess_data)

      expect(result["og:title"]).to eq("GitHub")
      expect(result["og:description"]).to eq("Where the world builds software")
      expect(result["og:image"]).to eq("https://github.com/favicon.png")

      cached = Jekyll::LinkCard::Cache.read("https://github.com")
      expect(cached).to eq(result)
    end
  end

  describe "cache behavior" do
    it "returns cached data on second call" do
      html = <<~HTML
        <html><head>
          <meta property="og:title" content="Cached Page" />
        </head></html>
      HTML

      stub_request(:get, "https://cached.com")
        .to_return(status: 200, body: html)

      tag = Jekyll::LinkCard::Tag.new("link_card", " https://cached.com ", nil)

      tag.send(:preprocess_data)
      expect(WebMock).to have_requested(:get, "https://cached.com").once

      tag.send(:preprocess_data)
      expect(WebMock).to have_requested(:get, "https://cached.com").once
    end
  end

  describe "hybrid mode" do
    it "reads from site data without HTTP" do
      site = double("site",
                    config: { "link_card" => { "mode" => "hybrid" } },
                    data: {
                      "link-cards" => {
                        "https://hybrid.com" => {
                          "og:title" => "Hybrid Card",
                          "og:description" => "From YAML",
                          "url" => "https://hybrid.com"
                        }
                      }
                    })

      tag = Jekyll::LinkCard::Tag.new("link_card", " https://hybrid.com ", nil)
      context = double("context", registers: { site: site })

      result = tag.render(context)

      expect(result).to include("Hybrid Card")
      expect(result).to include("From YAML")
      expect(WebMock).not_to have_requested(:get, "https://hybrid.com")
    end
  end
end
