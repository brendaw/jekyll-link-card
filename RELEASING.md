# Releasing

## Steps

1. Update version in `lib/jekyll/link_card/version.rb`
2. Update `CHANGELOG.md` with release notes
3. Commit changes:
   ```sh
   git add -A
   git commit -m "chore: release vX.Y.Z"
   ```
4. Create a git tag:
   ```sh
   git tag vX.Y.Z
   ```
5. Push:
   ```sh
   git push origin main --tags
   ```
6. Build and push to RubyGems:
   ```sh
   gem build jekyll-link-card.gemspec
   gem push jekyll-link-card-X.Y.Z.gem
   ```

## Versioning

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)
