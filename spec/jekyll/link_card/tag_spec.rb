require "spec_helper"

# Require only the modules we need, skipping tag.rb (which requires liquid)
require "jekyll/link_card/version"
require "jekyll/link_card/og_fetcher"
require "jekyll/link_card/cache"

# Load tag.rb in a controlled way after stubbing liquid
# Stub Liquid before loading tag
module Liquid
  class Tag
    def self.new(*); super; end
    def initialize(_tag_name, _markup, _parse_context); end
    def render(_context); ""; end
  end
  class Template
    def self.register_tag(_name, _klass); end
  end
end

require "jekyll/link_card/tag"

RSpec.describe Jekyll::LinkCard::Tag do
  let(:tag) { described_class.new("link_card", " https://example.com ", nil) }

  before do
    Jekyll::LinkCard::Tag.class_variable_set(:@@style_output, false)
  end

  describe "#build_html" do
    it "renders a complete link card" do
      og = {
        "og:title" => "Example",
        "og:description" => "A description",
        "og:image" => "https://example.com/img.png",
        "url" => "https://example.com"
      }

      html = tag.send(:build_html, og)

      expect(html).to include('class="link-card"')
      expect(html).to include('class="link-card-title"')
      expect(html).to include('class="link-card-description"')
      expect(html).to include('class="link-card-image"')
      expect(html).to include("Example")
      expect(html).to include("A description")
      expect(html).to include("https://example.com/img.png")
      expect(html).to include('href="https://example.com"')
    end

    it "omits description when empty" do
      og = { "og:title" => "Title", "url" => "https://example.com" }

      html = tag.send(:build_html, og)

      expect(html).not_to include("<p")
    end

    it "omits image when not present" do
      og = { "og:title" => "Title", "url" => "https://example.com" }

      html = tag.send(:build_html, og)

      expect(html).not_to include("<img")
    end

    it "includes <style> tag on first render" do
      og = { "og:title" => "Title", "url" => "https://example.com" }

      html = tag.send(:build_html, og)

      expect(html).to include("<style>")
      expect(html).to include(".link-card{")
    end

    it "excludes <style> tag on subsequent renders" do
      og = { "og:title" => "Title", "url" => "https://example.com" }

      tag.send(:build_html, og)
      html2 = tag.send(:build_html, og)

      expect(html2).not_to include("<style>")
    end
  end

  describe "#escape" do
    it "escapes HTML entities" do
      expect(tag.send(:escape, '<script>alert("xss")</script>')).to eq(
        "&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;"
      )
    end

    it "escapes ampersands" do
      expect(tag.send(:escape, "a & b")).to eq("a &amp; b")
    end
  end

  describe "#image_tag" do
    it "renders img tag with lazy loading" do
      html = tag.send(:image_tag, "https://example.com/img.png")

      expect(html).to include('<img src="https://example.com/img.png"')
      expect(html).to include('loading="lazy"')
      expect(html).to include('class="link-card-image"')
    end

    it "returns empty string when src is nil" do
      expect(tag.send(:image_tag, nil)).to eq("")
    end
  end

  describe "#description_tag" do
    it "renders p tag with description" do
      html = tag.send(:description_tag, "Hello world")

      expect(html).to include("<p")
      expect(html).to include("Hello world")
      expect(html).to include('class="link-card-description"')
    end

    it "returns empty string when text is empty" do
      expect(tag.send(:description_tag, "")).to eq("")
    end
  end

  describe "#preprocess_data" do
    it "returns cached data on hit" do
      allow(Jekyll::LinkCard::Cache).to receive(:read)
        .with("https://example.com")
        .and_return({ "og:title" => "Cached" })

      result = tag.send(:preprocess_data)

      expect(result).to eq({ "og:title" => "Cached" })
    end

    it "fetches and caches on miss" do
      allow(Jekyll::LinkCard::Cache).to receive(:read).and_return(nil)
      allow(Jekyll::LinkCard::OgFetcher).to receive(:fetch)
        .with("https://example.com")
        .and_return({ "og:title" => "Fresh" })
      allow(Jekyll::LinkCard::Cache).to receive(:write)

      result = tag.send(:preprocess_data)

      expect(result).to eq({ "og:title" => "Fresh" })
      expect(Jekyll::LinkCard::Cache).to have_received(:write)
        .with("https://example.com", { "og:title" => "Fresh" })
    end

    it "returns nil when fetch fails" do
      allow(Jekyll::LinkCard::Cache).to receive(:read).and_return(nil)
      allow(Jekyll::LinkCard::OgFetcher).to receive(:fetch).and_return(nil)

      expect(tag.send(:preprocess_data)).to be_nil
    end
  end

  describe "#hybrid_data" do
    it "reads from site data" do
      site = double("site", data: { "link-cards" => { "https://example.com" => { "og:title" => "Hybrid" } } })

      result = tag.send(:hybrid_data, site)

      expect(result).to eq({ "og:title" => "Hybrid" })
    end

    it "returns nil when URL not found" do
      site = double("site", data: { "link-cards" => {} })

      expect(tag.send(:hybrid_data, site)).to be_nil
    end

    it "returns nil when site data is nil" do
      site = double("site", data: nil)

      expect(tag.send(:hybrid_data, site)).to be_nil
    end
  end
end
