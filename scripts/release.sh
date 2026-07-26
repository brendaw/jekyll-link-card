#!/bin/bash
set -euo pipefail

# Release script for jekyll-link-card
# Usage: ./scripts/release.sh <version>
# Example: ./scripts/release.sh 0.2.0

if [ $# -ne 1 ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 0.2.0"
  exit 1
fi

VERSION="$1"

echo "Releasing v${VERSION}..."

# Run tests
echo "Running tests..."
bundle exec rspec
bundle exec rubocop

# Update version file
echo "Updating version to ${VERSION}..."
sed -i '' "s/VERSION = .*/VERSION = \"${VERSION}\"/" lib/jekyll/link_card/version.rb

# Build gem
echo "Building gem..."
gem build jekyll-link-card.gemspec

# Commit and tag
echo "Creating git tag..."
git add -A
git commit -m "chore: release v${VERSION}"
git tag "v${VERSION}"

echo ""
echo "Release v${VERSION} prepared!"
echo ""
echo "Next steps:"
echo "  git push origin main --tags"
echo "  gem push jekyll-link-card-${VERSION}.gem"
