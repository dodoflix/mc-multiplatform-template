# ModTemplate (replace with your mod name)

[![Build](https://github.com/yourusername/YourRepo/actions/workflows/ci.yml/badge.svg)](https://github.com/yourusername/YourRepo/actions/workflows/ci.yml)
[![GitHub Release](https://img.shields.io/github/v/release/yourusername/YourRepo?label=release)](https://github.com/yourusername/YourRepo/releases)
[![License](https://img.shields.io/github/license/yourusername/YourRepo)](LICENSE)

> ⚠️ **This is a template project.** Run `bash setup.sh` after cloning to personalise it.

A multi-platform Minecraft mod/plugin starter project supporting **Bukkit/Spigot/Paper**, **Fabric**, **Forge**, and **NeoForge**.

---

## 🚀 Quick Start

```bash
# 1. Click "Use this template" on GitHub (or clone)
git clone https://github.com/yourusername/YourRepo.git
cd YourRepo

# 2. Run the setup script — it asks a few questions and renames everything
bash setup.sh

# 3. Verify the stub code compiles
./gradlew :common:test
cd bukkit && ./gradlew build
```

That's it. Replace the stub `ExampleFeature` with your actual mod logic.

---

## 📦 Platform Support

| Platform | MC Version | Notes |
|----------|-----------|-------|
| **Bukkit/Spigot/Paper** | 1.21.11+ | Plugin JAR via Shadow |
| **Fabric** | 1.21.11 | Bundled via `include()` |
| **Forge** | 1.21.11 | Shadow with relocation |
| **NeoForge** | 1.21.11 | JAR-in-JAR via `jarJar` |
| **Quilt** | — | Use Fabric version |

---

## 🏗️ Architecture

```
YourRepo/
├── common/                 ← Pure Java business logic (no platform deps)
│   └── src/main/java/.../common/
│       ├── Constants.java  ← Shared constants (mod ID, permissions, etc.)
│       ├── ModConfig.java  ← Config interface (platform-agnostic)
│       └── ExampleFeature.java  ← Replace with your logic
├── bukkit/                 ← Bukkit/Spigot/Paper implementation
├── fabric/                 ← Fabric implementation
├── forge/                  ← Forge implementation
└── neoforge/               ← NeoForge implementation
```

**The "common first" rule:** All business logic lives in `common/`. Platform modules only wire platform APIs to the common core — they contain **no business logic**.

---

## ⚙️ CI/CD

This template uses [`mc-multiplatform-toolkit`](https://github.com/dodoflix/mc-multiplatform-toolkit) for reusable CI/CD workflows. Your `.github/workflows/` are just **10-line callers** — all logic is maintained centrally.

- **CI** (`ci.yml`): Unit tests → parallel platform builds → integration tests on PRs
- **Release** (`release.yml`): Auto version bump from [Conventional Commits](https://www.conventionalcommits.org/) → GitHub Release + Modrinth publish

### Required Secrets / Variables

| Name | Where | Description |
|------|-------|-------------|
| `MODRINTH_TOKEN` | Repository secret | Modrinth API token |
| `MODRINTH_PROJECT_ID` | Repository variable (`vars.*`) | Modrinth project ID/slug |

---

## 🔧 Building

```bash
# All platforms (run from each platform dir)
./gradlew :common:test          # common unit tests
cd bukkit   && ./gradlew build  # bukkit/build/libs/
cd fabric   && ./gradlew build  # fabric/build/libs/
cd forge    && ./gradlew build  # forge/build/libs/
cd neoforge && ./gradlew build  # neoforge/build/libs/
```

---

## 📝 License

MIT — see [LICENSE](LICENSE).
