# Contributing

Contributions are welcome! Please follow these guidelines.

## Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(bukkit): add per-world config support
fix(common): handle null profession correctly
docs: update README setup instructions
```

Types: `feat`, `fix`, `chore`, `refactor`, `perf`, `test`, `docs`, `ci`

## Code Style

- Java 21, UTF-8 encoding
- Javadoc on all `public` classes and methods
- Business logic only in `common/` — platforms are thin adapters
- Tests in `common/` using JUnit 5 + Mockito 5

## Pull Requests

1. Fork the repository
2. Create a feature branch from `develop`
3. Make your changes with tests
4. Open a PR targeting `develop`
