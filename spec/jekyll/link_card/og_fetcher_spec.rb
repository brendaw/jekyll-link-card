# frozen_string_literal: true

require "spec_helper"
require "jekyll/link_card/og_fetcher"

RSpec.describe Jekyll::LinkCard::OgFetcher do
  describe ".fetch" do
    it "returns OG metadata from a valid page" do
      html = <<~HTML
        <html><head>
          <meta property="og:title" content="Test Title" />
          <meta property="og:description" content="Test Description" />
          <meta property="og:image" content="https://example.com/image.png" />
        </head></html>
      HTML

      stub_request(:get, "https://example.com")
        .to_return(status: 200, body: html, headers: { "Content-Type" => "text/html" })

      result = described_class.fetch("https://example.com")

      expect(result).to eq(
        "og:title" => "Test Title",
        "og:description" => "Test Description",
        "og:image" => "https://example.com/image.png",
        "url" => "https://example.com"
      )
    end

    it "resolves relative image URLs" do
      html = <<~HTML
        <html><head>
          <meta property="og:title" content="Title" />
          <meta property="og:image" content="/assets/img.png" />
        </head></html>
      HTML

      stub_request(:get, "https://example.com")
        .to_return(status: 200, body: html)

      result = described_class.fetch("https://example.com")

      expect(result["og:image"]).to eq("https://example.com/assets/img.png")
    end

    it "returns nil when no OG tags found" do
      html = "<html><head><title>No OG</title></head></html>"

      stub_request(:get, "https://example.com")
        .to_return(status: 200, body: html)

      expect(described_class.fetch("https://example.com")).to be_nil
    end

    it "returns nil on HTTP error" do
      stub_request(:get, "https://example.com")
        .to_return(status: 404)

      expect(described_class.fetch("https://example.com")).to be_nil
    end

    it "returns nil on timeout" do
      stub_request(:get, "https://example.com").to_timeout

      expect(described_class.fetch("https://example.com")).to be_nil
    end

    it "sends correct User-Agent" do
      stub_request(:get, "https://example.com")
        .with(headers: { "User-Agent" => "JekyllLinkCard/0.1.0" })
        .to_return(status: 200, body: "<html></html>")

      described_class.fetch("https://example.com")
    end

    it "supports meta name attribute as fallback" do
      html = <<~HTML
        <html><head>
          <meta name="og:title" content="Name Attr" />
        </head></html>
      HTML

      stub_request(:get, "https://example.com")
        .to_return(status: 200, body: html)

      result = described_class.fetch("https://example.com")

      expect(result["og:title"]).to eq("Name Attr")
    end
  end
end
