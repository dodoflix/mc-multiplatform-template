# GitHub Copilot Instructions — mc-multiplatform-template

> **These instructions are authoritative.** Read this file before making any changes.
> After running `setup.sh`, update this file to reflect the actual project name and conventions.

---

## Project Overview

A GitHub Template repository for multi-platform Minecraft mods and plugins. Supports **Bukkit/Spigot/Paper**, **Fabric**, **Forge**, and **NeoForge** from a single shared core. Run `bash setup.sh` after cloning to personalise all placeholder values.

---

## Architecture

### Module Layout

```
YourRepo/                          ← Root Gradle project
├── common/                        ← Platform-agnostic core (ZERO platform deps)
├── bukkit/                        ← Bukkit/Spigot/Paper implementation
├── fabric/                        ← Fabric (Quilt-compatible) implementation
├── forge/                         ← Forge implementation
└── neoforge/                      ← NeoForge implementation
```

### The "Common First" Rule

All business logic lives in `common/`. Platform modules only wire platform APIs to the common core — they contain **no business logic**.

- `common` has **no dependencies** on Bukkit, Fabric, Forge, or NeoForge
- Each platform's config class implements `ModConfig`
- Each platform's event handler calls the common feature class and reacts to its result
- When adding a feature, always start in `common/`, then add thin platform adapters

---

## Package Conventions

```
me.example.modtemplate           ← Replace with your package after setup.sh
├── common.*                     ← shared interfaces, logic, utilities
├── bukkit.*                     ← Bukkit-specific (listeners/, config/)
├── fabric.*                     ← Fabric-specific (mixin/, config/)
├── forge.*                      ← Forge-specific (events/, config/)
└── neoforge.*                   ← NeoForge-specific (events/, config/)
```

Sub-package names mirror each other across platforms (e.g. `*.config`, `*.events`/`*.listeners`).

---

## Naming Conventions

| Concept | Pattern | Example |
|---|---|---|
| Main mod/plugin class | `<ModName><Platform>` | `ModTemplateForge` |
| Platform config | `<Platform>Config` implements `ModConfig` | `BukkitConfig` |
| Feature/logic class | Descriptive noun | `ExampleFeature` → replace with actual name |
| Constants | `UPPER_SNAKE_CASE` static final in `Constants.java` | `MOD_ID`, `PERMISSION_ADMIN` |
| Booleans | `is*`, `has*`, `should*` prefixes | `isEnabled()`, `shouldActivate()` |
| Classes/Interfaces | PascalCase | `ModConfig`, `ExampleFeature` |
| Methods/Fields | camelCase | `getDisabledWorlds()` |

---

## Language & Java Style

- **Java 21**, no Kotlin, no records, no sealed classes
- **UTF-8** source encoding
- Private fields with public getters/setters — no public fields
- Utility classes (like `Constants`) must have a private constructor
- Prefer explicit null checks (`!= null`) over `Optional` for simple guards

### Javadoc

All `public` classes and `public`/`protected` methods require Javadoc:

```java
/**
 * Determines if the feature should activate.
 *
 * @param worldName           the world the event occurred in
 * @param hasBypassPermission whether the player holds the bypass permission
 * @return {@code true} if the feature should activate
 */
public boolean shouldActivate(String worldName, boolean hasBypassPermission) { ... }
```

---

## Adding a New Feature Checklist

1. **common/** — implement logic; if config-driven, add method to `ModConfig` interface
2. **common/** — add unit tests covering all branches
3. **bukkit/config/BukkitConfig** — implement the new `ModConfig` method
4. **bukkit/** — wire into the relevant listener
5. **fabric/config/FabricConfig**, **forge/config/ForgeConfig**, **neoforge/config/NeoForgeConfig** — implement new method
6. **fabric/**, **forge/**, **neoforge/** — wire into relevant mixin/event handler
7. Update `plugin.yml` (Bukkit), `fabric.mod.json` (Fabric), and Forge/NeoForge resources if needed

---

## Testing

- Framework: **JUnit 5** + **Mockito 5**
- JaCoCo coverage for `common` module
- Parameterized tests preferred for logic with multiple input combinations
- Use `@Nested` classes to group related scenarios
- Mock platform objects with Mockito — never use real platform APIs in unit tests
- Run tests: `./gradlew :common:test`

### Test Naming

```java
@Test
void shouldActivate_whenFeatureEnabled() { ... }

@Test
void shouldNotActivate_whenWorldIsDisabled() { ... }
```

Format: `should<Outcome>_when<Condition>`

---

## Build System

- **Gradle** multi-module; each platform is an **independent** Gradle build with its own `gradlew`
- Version catalog: `gradle/libs.versions.toml` — all versions defined here, never hardcode inline
- `modVersion` in root `gradle.properties` is the single source of truth
- Bukkit and Forge use **Shadow JAR** with package relocation
- Fabric uses `include(project(":common"))`
- NeoForge uses `jarJar(project(":common"))`

### Useful Tasks

```bash
./gradlew :common:test              # Run common unit tests
cd bukkit && ./gradlew build        # Build Bukkit JAR
cd fabric && ./gradlew build        # Build Fabric JAR
cd forge && ./gradlew build         # Build Forge JAR  
cd neoforge && ./gradlew build      # Build NeoForge JAR
```

---

## CI/CD

Thin caller workflows in `.github/workflows/` delegate to
[`mc-multiplatform-toolkit`](https://github.com/dodoflix/mc-multiplatform-toolkit).

**Never edit CI logic here** — changes go in the toolkit repo.

```yaml
# .github/workflows/ci.yml — example caller (15 lines)
jobs:
  ci:
    uses: dodoflix/mc-multiplatform-toolkit/.github/workflows/ci.yml@main
    with:
      mod-name: YourModName
      mod-id: yourmodid
    secrets: inherit
```

---

## Conventional Commits

Every commit must follow [Conventional Commits](https://www.conventionalcommits.org/).

| Type | When | Version bump |
|------|------|-------------|
| `feat` | New user-facing feature | Minor |
| `fix` | Bug fix | Patch |
| `chore` | Maintenance (deps, build) | None |
| `refactor` | Code restructuring | None |
| `test` | Tests only | None |
| `docs` | Documentation only | None |

Scopes: `bukkit`, `fabric`, `forge`, `neoforge`, `common`, `deps`, `ci`

---

## Constants

All shared string literals live in `common/Constants.java`. Never hardcode mod ID, permission nodes, or config keys in platform code — always reference `Constants.*`.

---

## Key Design Decisions (Template Defaults)

- **AI + gravity check** — filters out NPC villagers from mods like Citizens
- **World-based disable list** — admins can allow trading in specific worlds
- **Bypass permission** — admins can bypass restrictions via `Constants.PERMISSION_ADMIN`
- **`ExampleFeature`** is a stub — replace the class name and logic with your actual feature after `setup.sh`
