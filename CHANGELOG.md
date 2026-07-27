# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.1] - 2026-07-26

### Changed

- Image now uses cover mode (fills and centers within container)
- Cards use full-width layout instead of max-width 600px

### Added

- Description truncation option (`truncation:N`) per-link or globally via `link_card.truncation`

## [0.1.0] - 2026-07-26

### Added

- Liquid tag `{% link_card URL %}` for rendering OG preview cards
- Open Graph metadata fetching via Nokogiri
- File-based caching with 24h TTL in `tmp/cache/link-card/`
- Hybrid mode support reading from `_data/link-cards.yml`
- Default CSS with responsive layout and lazy-loaded images
- RuboCop and RSpec test suite
- CI workflow with GitHub Actions
