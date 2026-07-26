# Contributing

Thanks for your interest in contributing to Jekyll Link Card!

## Development Setup

```sh
git clone https://github.com/brendaw/jekyll-link-card.git
cd jekyll-link-card
bundle install
```

## Running Tests

```sh
bundle exec rspec
```

## Linting

```sh
bundle exec rubocop
```

## Code Style

- Double quotes for strings
- 2-space indentation
- Run `rubocop` before submitting

## Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`bundle exec rspec`)
6. Ensure no lint errors (`bundle exec rubocop`)
7. Commit with a clear message
8. Push and open a Pull Request

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation changes
- `test:` adding tests
- `chore:` maintenance

## Reporting Issues

Use the [GitHub issue tracker](https://github.com/brendaw/jekyll-link-card/issues) to report bugs or request features.
