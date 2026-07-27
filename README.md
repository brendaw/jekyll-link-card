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
| `link_card.truncation` | `0` (no limit) | Max lines for description text |
| `link_card.display` | `inline` | `inline` (image left) or `block` (image top) |

### Truncation

Control description text truncation globally or per-link:

```yaml
# _config.yml — global (applies to all cards)
link_card:
  truncation: 2
```

```liquid
{% link_card https://example.com truncation:3 %}
```

Per-link overrides global. Set to `0` or omit for no limit.

### Display Mode

Choose between inline (horizontal) or block (vertical) layout:

```yaml
# _config.yml — global
link_card:
  display: block
```

```liquid
{% link_card https://example.com display:block %}
```

| Mode | Layout |
|------|--------|
| `inline` | Image left, title + description right (default) |
| `block` | Image top, title + description bottom |

## How It Works

1. **Preprocess mode**: Fetches the URL, extracts `og:title`, `og:description`, and `og:image` via Nokogiri
2. Caches the result in `tmp/cache/link-card/` (24h TTL, SHA256 key)
3. Renders a full-width HTML card with cover image and embedded CSS
4. **Hybrid mode**: Reads from `_data/link-cards.yml` (no HTTP requests)

## Integration Guide (Existing Jekyll Site)

Step-by-step to add link cards to your site:

### 1. Add the gem

```ruby
# Gemfile
gem "jekyll-link-card"
```

```sh
bundle install
```

### 2. Enable the plugin

```yaml
# _config.yml
plugins:
  - jekyll-link-card
```

> **GitHub Pages?** Add `gem "jekyll-link-card"` to `Gemfile` and create a `.github/workflows/jekyll.yml` that runs `bundle install` before build. Or use [jekyll-plugins](https://github.com/github/pages-gem#plugins) workaround.

### 3. Use in posts/pages

```liquid
{% link_card https://example.com %}
```

### 4. (Optional) Limit description length

```yaml
# _config.yml — global (2 lines max)
link_card:
  truncation: 2
```

Or per-link:

```liquid
{% link_card https://example.com truncation:1 %}
```

### 5. (Optional) Choose display mode

```yaml
# _config.yml — global (all cards vertical)
link_card:
  display: block
```

Or per-link:

```liquid
{% link_card https://example.com display:block %}
```

### 6. (Optional) Customize the card style

Cards use default CSS with full-width layout and cover images. To override, add to your stylesheet:

```css
.link-card { max-width: 500px; }
.link-card-title { color: #1a73e8; }
.link-card-description { font-size: 13px; }
```

### 6. (Optional) Switch to hybrid mode

If you have many cards and want faster builds, use hybrid mode:

```yaml
# _config.yml
link_card:
  mode: hybrid
```

Then define your cards in `_data/link-cards.yml`:

```yaml
https://example.com:
  og:title: Example Domain
  og:description: A description of the page.
  og:image: https://example.com/preview.png
```

### 6. Clear the cache

If a card looks stale, delete the cache:

```sh
rm -rf tmp/cache/link-card/
```

### Troubleshooting

| Problem | Solution |
|---------|----------|
| Card shows nothing | Check URL is accessible, check `tmp/cache/link-card/` |
| Build is slow | Switch to hybrid mode |
| Image not showing | Verify `og:image` is an absolute URL |
| CSS conflicts | Override `.link-card` classes in your stylesheet |

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
