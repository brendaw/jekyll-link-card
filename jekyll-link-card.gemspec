lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jekyll/link_card/version"

Gem::Specification.new do |s|
  s.name        = "jekyll-link-card"
  s.version     = Jekyll::LinkCard::VERSION
  s.authors     = ["William Brendaw"]
  s.email       = ["brendaw@example.com"]
  s.summary     = "Jekyll plugin that renders Open Graph preview cards via a Liquid tag"
  s.description = "Fetches Open Graph metadata and renders beautiful link preview cards in your Jekyll site."
  s.homepage    = "https://github.com/brendaw/jekyll-link-card"
  s.license     = "MIT"

  s.required_ruby_version = ">= 2.7.0"

  s.files         = Dir["lib/**/*", "LICENSE", "README.md"]
  s.require_paths = ["lib"]

  s.add_dependency "jekyll", ">= 3.5"
  s.add_dependency "nokogiri", "~> 1.0"
end
