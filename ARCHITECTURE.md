# Architecture

This document explains the design of the multi-platform project structure.

## Overview

```
YourRepo/                          ← Root Gradle project (common only)
├── common/                        ← Platform-agnostic Java module
│   ├── src/main/java/...common/
│   │   ├── Constants.java         ← All shared constants (mod ID, permissions)
│   │   ├── ModConfig.java         ← Config interface (platform-agnostic)
│   │   └── ExampleFeature.java    ← Business logic stub — replace with yours
│   └── src/test/                  ← JUnit 5 + Mockito unit tests
├── bukkit/                        ← Independent Gradle build (Bukkit/Spigot/Paper)
├── fabric/                        ← Independent Gradle build (Fabric/Quilt)
├── forge/                         ← Independent Gradle build (Forge)
├── neoforge/                      ← Independent Gradle build (NeoForge)
└── gradle/libs.versions.toml      ← Shared version catalog
```

## The "Common First" Rule

All business logic lives in `common/`. Platform modules only wire platform
APIs to the common core — they contain **no business logic**.

```
[Platform API Event] → [Platform Listener/Mixin] → [Common Logic] → [Result]
                                         ↑                ↑
                                   thin adapter      pure Java
```

This makes the logic unit-testable without any Minecraft server running.

## Gradle Architecture

The project uses an unusual but important pattern:

- **Root project** includes only `common/` as a Gradle subproject
- **Each platform** (bukkit, fabric, forge, neoforge) is an **independent** Gradle build with its own `gradlew`
- Platforms resolve `common` at build time via `includeBuild("../common")` + `dependencySubstitution`

```
Root build (./gradlew)
  └── :common (subproject)

Bukkit build (cd bukkit && ./gradlew)
  └── composite build → ../common (resolved as me.example:modtemplate-common)

Fabric build (cd fabric && ./gradlew)
  └── composite build → ../common
```

### Why independent Gradle builds?

Each Minecraft platform requires different Gradle plugins:
- **Bukkit**: Shadow JAR (no Gradle plugin requirement)
- **Fabric**: Fabric Loom (requires Gradle 9.x)
- **Forge**: ForgeGradle 6 (requires Gradle 8.x — **incompatible with Gradle 9**)
- **NeoForge**: NeoForge Moddev plugin

Running them in a single Gradle build would force a single Gradle version, which
is impossible given ForgeGradle's Gradle 8 requirement and Fabric Loom's Gradle 9 optimizations.

## Dependency Management

All dependency versions are defined once in `gradle/libs.versions.toml`.
Each platform reads this catalog via its `settings.gradle.kts`:

```kotlin
dependencyResolutionManagement {
    versionCatalogs {
        create("catalog") {
            from(files("../gradle/libs.versions.toml"))
        }
    }
}
```

## Bundling Strategy

Each platform handles the `common` dependency differently:

| Platform | Strategy | Why |
|----------|---------|-----|
| Bukkit | Shadow JAR (relocate common) | No mod loader, must be self-contained |
| Fabric | `include(project(":common"))` | Fabric supports nested JARs |
| Forge | Shadow JAR (relocate common) | Must be self-contained |
| NeoForge | `jarJar(project(":common"))` | NeoForge supports JAR-in-JAR |

Shadow relocation prevents classpath conflicts if two mods use the same library:

```
me.example.mymod.common → (bundled into) → me.example.mymod.bukkit.common
```

## CI/CD

CI and release workflows are maintained in
[mc-multiplatform-toolkit](https://github.com/dodoflix/mc-multiplatform-toolkit).
This project's `.github/workflows/` are thin callers that pass project-specific
inputs to the toolkit.

### Change Detection

The CI workflow uses `git diff` to detect whether any source files changed.
Pushes that only modify documentation, workflow files, or `gradle.properties`
are automatically skipped to save runner minutes.

## Adding a New Feature

1. **Design the interface** in `common/ModConfig.java` (if config-driven)
2. **Implement business logic** in `common/` with unit tests
3. **Add config implementation** in each platform's `Config.java`
4. **Wire into event handler** in each platform's listener/mixin/handler

## Adding a New Platform

1. Create `newplatform/` with its own `gradlew`, `build.gradle.kts`, `settings.gradle.kts`
2. Configure `settings.gradle.kts` with `includeBuild("../common")` + `dependencySubstitution`
3. Implement the `ModConfig` interface in `newplatform/config/`
4. Register events/mixins targeting `common` logic
5. Update root `settings.gradle.kts` to include the new platform
6. Update `.github/workflows/ci.yml` caller to pass `run-newplatform: true`
