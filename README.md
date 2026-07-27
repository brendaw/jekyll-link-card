<p align="center">
  <img src="https://badgen.net/github/license/brendaw/jekyll-link-card">
  <img src="https://badgen.net/badge/status/active/green">
  <img alt="Ruby" src="https://img.shields.io/badge/Ruby-2.7%2B-CC342D?logo=ruby&logoColor=white"/>
  <img alt="Jekyll" src="https://img.shields.io/badge/Jekyll-3.5%2B%20%7C%20%3C5.0-red?logo=jekyll&logoColor=white"/>
  <a href="https://github.com/brendaw/jekyll-link-card/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/brendaw/jekyll-link-card/actions/workflows/ci.yml/badge.svg"></a>
  <a href="https://github.com/brendaw/jekyll-link-card/issues"><img alt="Issues" src="https://badgen.net/github/open-issues/brendaw/jekyll-link-card"></a>
</p>

# jekyll-link-card

A Jekyll plugin that renders Open Graph preview cards from any URL via a Liquid tag.

## Features

- Renders link preview cards with **image, title, and description** from any URL
- Fetches OG metadata (`og:title`, `og:description`, `og:image`) via Nokogiri
- **File-based caching** with 24h TTL — builds stay fast after first run
- **Two display modes**: `inline` (image left) or `block` (image on top)
- **Description truncation** control (global or per-link)
- **Hybrid mode**: read from `_data/link-cards.yml` instead of fetching
- Full-width layout with cover images and lazy loading
- Runs automatically on `jekyll build` and `jekyll serve`

## Quick start

Get up and running in 5 minutes:

```bash
# 1. Add to your site's Gemfile
cat >> Gemfile <<'EOF'

gem "jekyll-link-card"
EOF

# 2. Install
bundle install

# 3. Add plugin to _config.yml
echo 'plugins:
  - jekyll-link-card' >> _config.yml

# 4. Use in any post or page
echo '{% link_card https://github.com %}' >> _posts/my-post.md

# 5. Build — cards render automatically
bundle exec jekyll build
```

> See [Installation](#1-installation-in-your-jekyll-site) for alternative
> install methods and [Configuration](#configuration-reference) for
> all options.

## Gem structure

```
lib/
  jekyll-link-card.rb                    # entry point
  jekyll/link_card/
    version.rb
    og_fetcher.rb       # fetch URL + parse OG tags via Nokogiri
    cache.rb            # file-based cache (SHA256 key, 24h TTL)
    tag.rb              # Liquid tag + HTML rendering
examples/site-integration/
  Gemfile.example
  _config.yml.example
scripts/
  changelog.sh
  release.sh
```

## 1. Installation in your Jekyll site

### Option A — from RubyGems (recommended)

In the site's `Gemfile`:

```ruby
gem "jekyll-link-card"
```

```bash
bundle install
```

### Option B — from GitHub

```ruby
gem "jekyll-link-card", git: "https://github.com/brendaw/jekyll-link-card", tag: "v0.2.0"
```

```bash
bundle install
```

### Option C — vendored (local copy)

Clone or copy the gem into the site repo:

```bash
cp -r jekyll-link-card vendor/jekyll-link-card
```

In the site's `Gemfile`:

```ruby
gem "jekyll-link-card", path: "vendor/jekyll-link-card"
```

```bash
bundle install
```

## 2. Usage

### Basic — just add a URL

```liquid
{% link_card https://example.com %}
```

### With truncation

Limit description to 2 lines:

```liquid
{% link_card https://example.com truncation:2 %}
```

### With display mode

Vertical layout (image on top):

```liquid
{% link_card https://example.com display:block %}
```

### Combine options

```liquid
{% link_card https://example.com truncation:1 display:block %}
```

## 3. Hybrid mode (for many cards)

If you have many link cards and want faster builds, use hybrid mode.
No HTTP requests are made — data is read from a YAML file.

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

https://another.com:
  og:title: Another Site
  og:description: A description here.
  og:image: https://another.com/preview.png
```

## Configuration reference

All options go in `_config.yml` under `link_card:`

```yaml
link_card:
  mode: preprocess      # preprocess | hybrid
  truncation: 2         # 0 = no limit, N = max lines
  display: inline       # inline | block
```

| Key | Default | Description |
|-----|---------|-------------|
| `link_card.mode` | `preprocess` | `preprocess` (fetch + cache) or `hybrid` (read from YAML) |
| `link_card.truncation` | `0` | Max lines for description text. `0` = no limit |
| `link_card.display` | `inline` | `inline` (image left) or `block` (image top) |

Per-link options override global config:

```liquid
{% link_card https://example.com truncation:1 display:block %}
```

## How it works

1. **Preprocess mode** (default): Fetches the URL, extracts `og:title`, `og:description`, and `og:image` via Nokogiri
2. Caches the result in `tmp/cache/link-card/` (24h TTL, SHA256 key)
3. Renders a full-width HTML card with cover image and embedded CSS
4. **Hybrid mode**: Reads from `_data/link-cards.yml` (no HTTP requests)

## CSS customization

Cards use default CSS with full-width layout and cover images.
Override in your stylesheet:

```css
.link-card { max-width: 500px; }
.link-card-title { color: #1a73e8; }
.link-card-description { font-size: 13px; }
```

## Clearing the cache

```sh
rm -rf tmp/cache/link-card/
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Card shows nothing | Check URL is accessible, check `tmp/cache/link-card/` |
| Build is slow | Switch to hybrid mode |
| Image not showing | Verify `og:image` is an absolute URL |
| CSS conflicts | Override `.link-card` classes in your stylesheet |

## Running the gem's own tests

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Contributing

Contributions are welcome — bug fixes, new features, documentation improvements, and translations.
See [CONTRIBUTING.md](CONTRIBUTING.md) for the development workflow.

The project uses GitHub Actions for CI (gem build, RuboCop linting, and unit tests across Ruby 3.0, 3.1, 3.2, and 3.3).

[Issues](https://github.com/brendaw/jekyll-link-card/issues) and
[Pull Requests](https://github.com/brendaw/jekyll-link-card/pulls) are open for your contribution.

## Contributors

See the [AUTHORS](AUTHORS.md) file for the amazing contributors of this project.

## License

[MIT](LICENSE) — William Brendaw and the contributors — 2026
