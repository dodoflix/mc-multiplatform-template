# Contributing

Thank you for wanting to contribute! Please read this guide before opening a PR.

## Getting Started

1. Fork the repository and clone your fork
2. Create a feature branch from `develop`: `git checkout -b feat/my-feature`
3. Make your changes (see guidelines below)
4. Open a pull request targeting `develop`

## Code Guidelines

### The "Common First" Rule

All business logic **must** live in `common/`. Platform modules are thin adapters only.

**Correct:**
```java
// common/ExampleFeature.java
public boolean shouldActivate(String worldName, boolean hasBypassPermission) { ... }

// bukkit/listeners/ExampleListener.java
if (feature.shouldActivate(world, player.hasPermission(PERM))) { event.setCancelled(true); }
```

**Incorrect — platform code in common:**
```java
// common/ExampleFeature.java  ❌
import org.bukkit.entity.Player;  // NO platform imports in common
```

### Testing

- All new features in `common/` require JUnit 5 + Mockito unit tests
- Test naming convention: `should<Outcome>_when<Condition>` (e.g. `shouldBlock_whenWorldIsDisabled`)
- Use `@Nested` classes to group related tests
- Never use real platform APIs in unit tests — use Mockito mocks

```bash
./gradlew :common:test
```

### Javadoc

All `public` classes and `public`/`protected` methods require Javadoc:

```java
/**
 * Determines if the feature should activate.
 *
 * @param worldName           the world name to check
 * @param hasBypassPermission whether the player has bypass permission
 * @return {@code true} if the feature should activate
 */
public boolean shouldActivate(String worldName, boolean hasBypassPermission) { ... }
```

### Code Style

- **Java 21**, UTF-8 encoding
- 4-space indentation for Java; 2-space for YAML/JSON
- Private fields with public getters — no public mutable fields
- Prefer explicit null checks over `Optional` for simple guards

## Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(bukkit): add per-world config support
fix(common): handle null world name
test(common): add parameterized tests for ExampleFeature
docs: update README setup instructions
chore(deps): bump fabric-api to 0.19.0
```

Types: `feat`, `fix`, `chore`, `refactor`, `perf`, `test`, `docs`, `ci`

## Adding a New Feature

Follow this checklist:

1. `common/ModConfig.java` — add config method if needed
2. `common/ExampleFeature.java` (or new class) — implement business logic
3. `common/src/test/` — add unit tests
4. `bukkit/config/BukkitConfig.java` — implement new config method
5. `bukkit/listeners/` — wire into listener
6. `fabric/config/FabricConfig.java` — implement new config method
7. `fabric/` — wire into mixin/event
8. Repeat for `forge/` and `neoforge/`
9. Update `README.md` if user-facing behaviour changed

## Adding a New Platform

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed instructions.

## Questions?

Open a [GitHub Discussion](https://github.com/yourusername/YourRepo/discussions) for questions.
