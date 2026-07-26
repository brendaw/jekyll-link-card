# Jekyll Link Card

A Jekyll plugin that renders Open Graph preview cards from any URL via a Liquid tag.

## Quick Start

Add to your `Gemfile`:

```ruby
gem "jekyll-link-card"
```

Then in your `_config.yml`:

```yaml
plugins:
  - jekyll-link-card
```

Use in any post or page:

```liquid
{% link_card https://github.com %}
```

## Installation

### Jekyll Sites

1. Add `gem "jekyll-link-card"` to your `Gemfile`
2. Run `bundle install`
3. Add `jekyll-link-card` to `plugins` in `_config.yml`

### As a Gem

```sh
gem install jekyll-link-card
```

## Usage

### Preprocess Mode (Default)

Fetches OG metadata at build time and caches for 24 hours:

```liquid
{% link_card https://example.com %}
```

### Hybrid Mode

Reads from `_data/link-cards.yml` instead of fetching:

```yaml
# _config.yml
link_card:
  mode: hybrid
```

```yaml
# _data/link-cards.yml
https://example.com:
  og:title: Example Domain
  og:description: This domain is for use in examples.
  og:image: https://example.com/image.png
```

## Configuration

| Key | Default | Description |
|-----|---------|-------------|
| `link_card.mode` | `preprocess` | `preprocess` (fetch + cache) or `hybrid` (read from YAML) |

## How It Works

1. **Preprocess mode**: Fetches the URL, extracts `og:title`, `og:description`, and `og:image` via Nokogiri
2. Caches the result in `tmp/cache/link-card/` (24h TTL, SHA256 key)
3. Renders an HTML card with embedded CSS
4. **Hybrid mode**: Reads from `_data/link-cards.yml` (no HTTP requests)

## Development

```sh
git clone https://github.com/brendaw/jekyll-link-card.git
cd jekyll-link-card
bundle install
bundle exec rspec    # Run tests
bundle exec rubocop  # Lint
```

## License

MIT
