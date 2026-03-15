# GitHub Copilot Instructions — mc-multiplatform-template

> **These instructions are authoritative.** Read this file before making any changes.
> After running `setup.sh`, update this file to reflect the actual project name and conventions.

---

## Development Workflow

### Task Size Gating — Plan Before Acting

Assess scope before writing any code:

**Always plan first when ANY of these are true:**
- New feature class, new module, or new config option is being added
- Task touches more than 3 files
- The request requires a decision about design (e.g. where logic lives, what the API looks like)
- Changes to `ModConfig` interface (impacts all 4 platforms simultaneously)

**Planning steps:**
1. Use `explore` agent to understand the current codebase structure and conventions
2. Write a plan to the session plan file; break into ordered todos in the SQL `todos` table
3. Confirm the plan with the user before writing code

**Start directly (no plan needed):**
- Single-file bug fix or documentation update
- Dependency version bump in `libs.versions.toml`

---

### Sub-Agent Dispatch — One Agent Per Lifecycle Phase

Delegate each phase to the right specialised agent. Do not implement in main context what a sub-agent can handle.

| Phase | Agent type | Example use |
|---|---|---|
| **Explore** | `explore` | "Find all implementations of `ModConfig`. What methods does it require?" |
| **TDD — write tests** | `general-purpose` | "Write failing JUnit 5 tests in `common/` for the new feature behaviour." |
| **Implement** | `general-purpose` | "Implement the feature to make the failing tests pass." |
| **Platform wiring** | `general-purpose` | "Wire the new feature into all 4 platform event handlers." |
| **Build & test** | `task` | Run `./gradlew :common:test` or full build; returns output only on failure. |
| **Code review** | `code-review` | Review all staged changes before committing. |

**Parallelise independent work:** Multiple `explore` agents can run in one response. `task` agents run in background — continue planning while they build. Never re-read files an `explore` agent already reported.

---

### Reference Consistency Check

**After every change — before committing — scan for stale references.**

Any time you rename, move, or change the behaviour of something, grep for the old name across the whole repo:

```bash
# Find all references to a renamed file, class, method, or concept
grep -r "old-name" . --include="*.md" --include="*.java" --include="*.yml" --include="*.toml"
```

Things to check after common change types:

- **Class/method renamed** → grep old name in all source files, tests, and docs
- **Config key or permission node changed** → grep in docs, `plugin.yml`, `fabric.mod.json`, README, copilot instructions
- **Workflow renamed** → grep old name in README, this file, and badge URLs
- **New feature added** → check if README, CHANGELOG, and copilot instructions need updating
- **`ModConfig` method added/renamed** → verify all 4 platform `Config` classes still implement it

**Fix every stale reference in the same commit as the original change.** A rename with dangling references is an incomplete commit.

---

### TDD — Test-Driven Development

All logic in `common/` **must** follow TDD. Platform wiring uses mocks.

**The cycle:**

1. **Write the failing test** (`common/src/test/java/…`):
   ```java
   @Test
   void should<Outcome>_when<Condition>() {
       // Arrange → Act → Assert
   }
   ```
2. **Run**: `task` agent → `./gradlew :common:test` — confirm test **fails** (not compile-error)
3. **Implement** minimum logic to make it pass — no extra code
4. **Run again**: confirm **green**
5. **Refactor** if needed, re-run
6. **Code review**: `code-review` agent — test + implementation staged together
7. **Commit** test + implementation in one commit

For `ExampleFeature` stub: when replacing with real logic, always delete `ExampleFeatureTest` and write new tests for the actual feature before implementing it.

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
