#!/bin/bash
set -euo pipefail

# Generate changelog from git commits since last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LAST_TAG" ]; then
  echo "## [Unreleased]" > /tmp/changelog_section.md
  git log --pretty=format:"- %s" >> /tmp/changelog_section.md
else
  echo "Comparing against tag: $LAST_TAG"
  echo "" > /tmp/changelog_section.md
  git log "${LAST_TAG}..HEAD" --pretty=format:"- %s" >> /tmp/changelog_section.md
fi

echo ""
echo "=== Changelog since ${LAST_TAG:-initial commit} ==="
echo ""
cat /tmp/changelog_section.md
echo ""
