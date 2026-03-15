# ModTemplate (replace with your mod name)

[![Build](https://github.com/yourusername/YourRepo/actions/workflows/ci.yml/badge.svg)](https://github.com/yourusername/YourRepo/actions/workflows/ci.yml)
[![GitHub Release](https://img.shields.io/github/v/release/yourusername/YourRepo?label=release)](https://github.com/yourusername/YourRepo/releases)
[![License](https://img.shields.io/github/license/yourusername/YourRepo)](LICENSE)

> ⚠️ **This is a template project.** Click **Use this template** on GitHub, then run `bash setup.sh` to personalise it.

A multi-platform Minecraft mod/plugin starter project supporting **Bukkit/Spigot/Paper**, **Fabric**, **Forge**, and **NeoForge** from a single shared Java core.

---

## 🚀 Quick Start

```bash
# 1. Click "Use this template" on GitHub (do NOT clone this repo directly)

# 2. Clone your new repo
git clone https://github.com/yourusername/YourRepo.git
cd YourRepo

# 3. Run the setup script — renames everything to your mod name/ID
bash setup.sh

# 4. Verify the stub compiles and tests pass
./gradlew :common:test
```

That's it. Replace `ExampleFeature` with your actual mod logic — start in `common/`, then wire each platform.

---

## 📦 Platform Support

| Platform | MC Version | Packaging |
|----------|-----------|-----------|
| **Bukkit/Spigot/Paper** | 1.21.11+ | Shadow JAR with relocation |
| **Fabric** | 1.21.11 | `include()` (bundled JAR) |
| **Forge** | 1.21.11 | Shadow JAR with relocation |
| **NeoForge** | 1.21.11 | `jarJar` (JAR-in-JAR) |
| **Quilt** | — | Use the Fabric JAR |

---

## 🏗️ Architecture

```
YourRepo/
├── common/                      ← Pure Java business logic (zero platform deps)
│   └── src/main/java/.../common/
│       ├── Constants.java       ← Shared constants (mod ID, permissions, etc.)
│       ├── ModConfig.java       ← Config interface (implemented per platform)
│       └── ExampleFeature.java  ← Replace with your logic
├── bukkit/                      ← Bukkit/Spigot/Paper implementation
├── fabric/                      ← Fabric implementation
├── forge/                       ← Forge implementation
└── neoforge/                    ← NeoForge implementation
```

**The "common first" rule:** all business logic lives in `common/`. Platform modules are thin adapters — they wire platform events to common logic and contain **no business logic** themselves.

See [ARCHITECTURE.md](ARCHITECTURE.md) for a deeper dive.

---

## ⚙️ CI/CD

Powered by [`mc-multiplatform-toolkit`](https://github.com/dodoflix/mc-multiplatform-toolkit). The workflows in `.github/workflows/` are **thin callers** (≤ 25 lines each) — all CI/CD logic is maintained centrally in the toolkit.

### Pipeline

```
push / PR
    │
    ▼
  CI (ci.yml)
  ├── Unit tests (JUnit 5 + JaCoCo coverage → Codecov)
  ├── Platform builds (Bukkit, Fabric, Forge, NeoForge) in parallel
  └── Integration tests (on PRs and pushes to master/develop)
         │
         │  workflow_run (only on CI success)
         ▼
  CD (cd.yml)
  ├── Compute next version from Conventional Commits
  ├── Build release JARs for all platforms
  ├── Create GitHub Release with changelog
  └── Publish to Modrinth
```

CD only triggers when CI passes — releases cannot happen from a broken build.

### Branch Strategy

| Branch | Purpose |
|--------|---------|
| `master` | Production — tagged releases only |
| `develop` | Integration — merge features here first |
| `feature/*`, `fix/*`, `chore/*` | Short-lived work branches |

### Required Secrets & Variables

| Name | Type | Description |
|------|------|-------------|
| `MODRINTH_TOKEN` | Repository secret | Modrinth API token for publishing |
| `CODECOV_TOKEN` | Repository secret | Codecov upload token for coverage reports |
| `MODRINTH_PROJECT_ID` | Repository variable | Your Modrinth project ID or slug |

---

## 🔧 Building Locally

```bash
./gradlew :common:test           # Run common unit tests
cd bukkit   && ./gradlew build   # → bukkit/build/libs/
cd fabric   && ./gradlew build   # → fabric/build/libs/
cd forge    && ./gradlew build   # → forge/build/libs/
cd neoforge && ./gradlew build   # → neoforge/build/libs/
```

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). All commits must follow [Conventional Commits](https://www.conventionalcommits.org/) — the CD pipeline uses them to determine version bumps automatically.

---

## 📝 License

MIT — see [LICENSE](LICENSE).
