#!/usr/bin/env bash
# setup.sh — Initialises a new project from the mc-multiplatform-template.
# Run once after cloning: bash setup.sh
# Replaces placeholders, renames files/directories, then removes itself.

set -euo pipefail

# ─── Cross-platform sed ──────────────────────────────────────────────────────
# macOS requires `sed -i ''`; GNU sed uses `sed -i`
if sed --version 2>/dev/null | grep -q GNU; then
    SED_INPLACE() { sed -i "$@"; }
else
    SED_INPLACE() { local expr="$1"; shift; sed -i '' "$expr" "$@"; }
fi

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}[info]${NC}  $*"; }
success() { echo -e "${GREEN}[ok]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[warn]${NC}  $*"; }
error()   { echo -e "${RED}[error]${NC} $*"; exit 1; }

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   mc-multiplatform-template — Project Setup   ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}"
echo ""

# ─── Helpers ─────────────────────────────────────────────────────────────────

read_input() {
    local prompt="$1"
    local default="${2:-}"
    local value
    if [ -n "$default" ]; then
        read -rp "$(echo -e "${YELLOW}?${NC} ${prompt} [${default}]: ")" value
        echo "${value:-$default}"
    else
        while true; do
            read -rp "$(echo -e "${YELLOW}?${NC} ${prompt}: ")" value
            [ -n "$value" ] && break
            warn "This field is required."
        done
        echo "$value"
    fi
}

read_yn() {
    local prompt="$1"
    local default="${2:-y}"
    local value
    read -rp "$(echo -e "${YELLOW}?${NC} ${prompt} [${default}]: ")" value
    value="${value:-$default}"
    [[ "$value" =~ ^[Yy] ]] && echo "true" || echo "false"
}

validate_mod_id() {
    # Must be lowercase alphanumeric only, 2-32 chars
    echo "$1" | grep -qE '^[a-z][a-z0-9]{1,31}$'
}

validate_package() {
    # Must be valid Java package: letters/numbers/dots, no trailing dot
    echo "$1" | grep -qE '^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$'
}

to_lower_no_sep() { echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d '-_ '; }

# ─── Gather inputs ────────────────────────────────────────────────────────────

echo -e "Answer the following questions to configure your project."
echo -e "Press ${CYAN}Enter${NC} to accept the default shown in brackets.\n"

# Mod name
MOD_NAME=$(read_input "Mod/plugin display name (PascalCase, e.g. MyMod)" "MyMod")

# Mod ID — validate
while true; do
    MOD_ID=$(read_input "Mod ID (lowercase a-z0-9, no spaces/dashes, 2-32 chars)" "$(to_lower_no_sep "$MOD_NAME")")
    validate_mod_id "$MOD_ID" && break
    warn "Mod ID must be lowercase letters and digits only (e.g. 'mymod'). Got: '$MOD_ID'"
done

# Modrinth slug — may include dashes
MOD_SLUG=$(read_input "Modrinth/URL slug (e.g. my-mod)" "$MOD_ID")

# Java base package — validate
while true; do
    PACKAGE=$(read_input "Java base package (e.g. com.yourname)" "me.example")
    validate_package "$PACKAGE" && break
    warn "Package must be lowercase dot-separated identifiers (e.g. 'com.yourname'). Got: '$PACKAGE'"
done

AUTHOR=$(read_input "Author name" "yourname")
GITHUB_OWNER=$(read_input "GitHub username/org" "yourusername")
GITHUB_REPO=$(read_input "GitHub repository name" "$MOD_NAME")
DESCRIPTION=$(read_input "Short description" "A Minecraft mod.")
MC_VERSION=$(read_input "Minecraft version" "1.21.11")
JAVA_VERSION=$(read_input "Java version" "21")

echo ""
echo -e "${CYAN}── Platform Selection ───────────────────────────────${NC}"
echo -e "Choose which platforms to include. Unused platforms will be removed.\n"
INCLUDE_BUKKIT=$(read_yn "Include Bukkit/Spigot/Paper?" "y")
INCLUDE_FABRIC=$(read_yn "Include Fabric?" "y")
INCLUDE_FORGE=$(read_yn  "Include Forge?" "y")
INCLUDE_NEOFORGE=$(read_yn "Include NeoForge?" "y")

[ "$INCLUDE_BUKKIT" = "false" ] && [ "$INCLUDE_FABRIC" = "false" ] && \
[ "$INCLUDE_FORGE" = "false" ] && [ "$INCLUDE_NEOFORGE" = "false" ] && \
    error "At least one platform must be included."

echo ""
echo -e "${CYAN}── Summary ──────────────────────────────────────────${NC}"
echo -e "  Mod name:      ${GREEN}${MOD_NAME}${NC}"
echo -e "  Mod ID:        ${GREEN}${MOD_ID}${NC}"
echo -e "  Slug:          ${GREEN}${MOD_SLUG}${NC}"
echo -e "  Package:       ${GREEN}${PACKAGE}.${MOD_ID}${NC}"
echo -e "  Author:        ${GREEN}${AUTHOR}${NC}"
echo -e "  GitHub:        ${GREEN}${GITHUB_OWNER}/${GITHUB_REPO}${NC}"
echo -e "  Description:   ${GREEN}${DESCRIPTION}${NC}"
echo -e "  MC version:    ${GREEN}${MC_VERSION}${NC}"
echo -e "  Java version:  ${GREEN}${JAVA_VERSION}${NC}"
echo -e "  Platforms:     ${GREEN}$([ "$INCLUDE_BUKKIT" = "true" ] && printf "Bukkit ")$([ "$INCLUDE_FABRIC" = "true" ] && printf "Fabric ")$([ "$INCLUDE_FORGE" = "true" ] && printf "Forge ")$([ "$INCLUDE_NEOFORGE" = "true" ] && printf "NeoForge")${NC}"
echo ""

read -rp "$(echo -e "${YELLOW}?${NC} Proceed? [Y/n]: ")" confirm
[[ "$confirm" =~ ^[Nn] ]] && { info "Aborted."; exit 0; }
echo ""

# ─── Derived values ───────────────────────────────────────────────────────────
PACKAGE_PATH="${PACKAGE//./\/}"     # me.example → me/example
PACKAGE_PATH_OLD="me/example"
PACKAGE_OLD="me.example"
MOD_ID_OLD="modtemplate"
MOD_NAME_OLD="ModTemplate"

# ─── Step 1: Remove unused platforms ─────────────────────────────────────────

info "Removing unused platforms..."
[ "$INCLUDE_BUKKIT"   = "false" ] && rm -rf bukkit   && info "  Removed bukkit/"
[ "$INCLUDE_FABRIC"   = "false" ] && rm -rf fabric   && info "  Removed fabric/"
[ "$INCLUDE_FORGE"    = "false" ] && rm -rf forge    && info "  Removed forge/"
[ "$INCLUDE_NEOFORGE" = "false" ] && rm -rf neoforge && info "  Removed neoforge/"

# Update root settings.gradle.kts to remove unused platforms from include list
[ "$INCLUDE_BUKKIT"   = "false" ] && SED_INPLACE '/run-bukkit: true/d' .github/workflows/ci.yml .github/workflows/release.yml 2>/dev/null || true
[ "$INCLUDE_FABRIC"   = "false" ] && SED_INPLACE '/run-fabric: true/d' .github/workflows/ci.yml .github/workflows/release.yml 2>/dev/null || true
[ "$INCLUDE_FORGE"    = "false" ] && SED_INPLACE '/run-forge: true/d'  .github/workflows/ci.yml .github/workflows/release.yml 2>/dev/null || true
[ "$INCLUDE_NEOFORGE" = "false" ] && SED_INPLACE '/run-neoforge: true/d' .github/workflows/ci.yml .github/workflows/release.yml 2>/dev/null || true

[ "$INCLUDE_BUKKIT"   = "false" ] && SED_INPLACE '/run-bukkit: false/d' .github/workflows/ci.yml .github/workflows/release.yml 2>/dev/null || true
[ "$INCLUDE_FABRIC"   = "false" ] && SED_INPLACE '/run-fabric: false/d' .github/workflows/ci.yml .github/workflows/release.yml 2>/dev/null || true
[ "$INCLUDE_FORGE"    = "false" ] && SED_INPLACE '/run-forge: false/d'  .github/workflows/ci.yml .github/workflows/release.yml 2>/dev/null || true
[ "$INCLUDE_NEOFORGE" = "false" ] && SED_INPLACE '/run-neoforge: false/d' .github/workflows/ci.yml .github/workflows/release.yml 2>/dev/null || true

success "Platform selection applied."

# ─── Step 2: Replace tokens in all text files ────────────────────────────────

info "Replacing placeholder tokens in all files..."

replace_in_file() {
    local file="$1"
    SED_INPLACE \
        "s|${PACKAGE_OLD}/${MOD_ID_OLD}|${PACKAGE_PATH}/${MOD_ID}|g" "$file"
    SED_INPLACE \
        "s|${PACKAGE_OLD}\.${MOD_ID_OLD}|${PACKAGE}.${MOD_ID}|g" "$file"
    SED_INPLACE \
        "s|${PACKAGE_OLD}|${PACKAGE}|g" "$file"
    SED_INPLACE \
        "s|${MOD_NAME_OLD}|${MOD_NAME}|g" "$file"
    SED_INPLACE \
        "s|${MOD_ID_OLD}|${MOD_ID}|g" "$file"
    SED_INPLACE \
        "s|yourusername/YourRepo|${GITHUB_OWNER}/${GITHUB_REPO}|g" "$file"
    SED_INPLACE \
        "s|yourusername|${GITHUB_OWNER}|g" "$file"
    SED_INPLACE \
        "s|YourRepo|${GITHUB_REPO}|g" "$file"
    SED_INPLACE \
        "s|yourname|${AUTHOR}|g" "$file"
    SED_INPLACE \
        "s|A Minecraft mod template\.|${DESCRIPTION}|g" "$file"
    SED_INPLACE \
        "s|A Minecraft plugin template\.|${DESCRIPTION}|g" "$file"
}

while IFS= read -r -d '' file; do
    replace_in_file "$file"
done < <(find . \
    ! -path './.git/*' \
    ! -path './setup.sh' \
    ! -name '*.jar' \
    ! -name '*.class' \
    ! -name '*.png' \
    ! -name '*.ico' \
    -type f -print0)

success "Token replacement complete."

# ─── Step 3: Rename Java source directories ──────────────────────────────────

info "Renaming source directories..."

rename_src_dir() {
    local base="$1"
    local old_src="${base}/src/main/java/${PACKAGE_PATH_OLD}/${MOD_ID_OLD}"
    local new_src="${base}/src/main/java/${PACKAGE_PATH}/${MOD_ID}"
    if [ -d "$old_src" ]; then
        mkdir -p "$(dirname "$new_src")"
        mv "$old_src" "$new_src"
        find "${base}/src/main/java/${PACKAGE_PATH_OLD}" -empty -type d -delete 2>/dev/null || true
    fi
    local old_test="${base}/src/test/java/${PACKAGE_PATH_OLD}/${MOD_ID_OLD}"
    local new_test="${base}/src/test/java/${PACKAGE_PATH}/${MOD_ID}"
    if [ -d "$old_test" ]; then
        mkdir -p "$(dirname "$new_test")"
        mv "$old_test" "$new_test"
        find "${base}/src/test/java/${PACKAGE_PATH_OLD}" -empty -type d -delete 2>/dev/null || true
    fi
}

rename_src_dir "common"
[ "$INCLUDE_BUKKIT"   = "true" ] && rename_src_dir "bukkit"
[ "$INCLUDE_FABRIC"   = "true" ] && rename_src_dir "fabric"
[ "$INCLUDE_FORGE"    = "true" ] && rename_src_dir "forge"
[ "$INCLUDE_NEOFORGE" = "true" ] && rename_src_dir "neoforge"

success "Source directories renamed."

# ─── Step 4: Rename Java source and resource files ───────────────────────────

info "Renaming Java class files..."
while IFS= read -r -d '' f; do
    dir=$(dirname "$f")
    base=$(basename "$f")
    newbase="${base//${MOD_NAME_OLD}/${MOD_NAME}}"
    [ "$base" != "$newbase" ] && mv "$f" "$dir/$newbase"
done < <(find . ! -path './.git/*' \( -name "*.java" -o -name "*.kt" \) -print0)

info "Renaming resource files..."
while IFS= read -r -d '' f; do
    dir=$(dirname "$f")
    base=$(basename "$f")
    newbase="${base//${MOD_ID_OLD}/${MOD_ID}}"
    [ "$base" != "$newbase" ] && mv "$f" "$dir/$newbase"
done < <(find . ! -path './.git/*' \( -name "${MOD_ID_OLD}.mixins.json" -o -name "${MOD_ID_OLD}.accesswidener" \) -print0)

success "Files renamed."

# ─── Step 5: Update version catalog and build files ──────────────────────────

info "Updating Minecraft version and Java version..."
SED_INPLACE "s|^minecraft = \".*\"|minecraft = \"${MC_VERSION}\"|g" gradle/libs.versions.toml
SED_INPLACE "s|^neoforge-mc = \".*\"|neoforge-mc = \"${MC_VERSION}\"|g" gradle/libs.versions.toml

for f in build.gradle.kts common/build.gradle.kts bukkit/build.gradle.kts \
          fabric/build.gradle.kts forge/build.gradle.kts neoforge/build.gradle.kts; do
    [ -f "$f" ] && SED_INPLACE "s|JavaLanguageVersion.of([0-9]*)|JavaLanguageVersion.of(${JAVA_VERSION})|g" "$f"
done
for f in gradle.properties bukkit/gradle.properties fabric/gradle.properties \
          forge/gradle.properties neoforge/gradle.properties; do
    [ -f "$f" ] && SED_INPLACE "s|javaVersion=.*|javaVersion=${JAVA_VERSION}|g" "$f"
done

# ─── Step 6: Update root settings.gradle.kts project name ────────────────────

SED_INPLACE "s|rootProject.name = \"${MOD_NAME_OLD}\"|rootProject.name = \"${MOD_NAME}\"|g" settings.gradle.kts

# ─── Step 7: Patch CI/CD workflows ───────────────────────────────────────────

info "Patching CI/CD caller workflows..."
for wf in .github/workflows/ci.yml .github/workflows/release.yml; do
    [ -f "$wf" ] || continue
    SED_INPLACE "s|java-version: '21'|java-version: '${JAVA_VERSION}'|g" "$wf"
done

# ─── Step 8: Create platform config stubs ────────────────────────────────────

if [ "$INCLUDE_BUKKIT" = "true" ]; then
    mkdir -p bukkit/src/main/resources
    cat > bukkit/src/main/resources/config.yml << YAML
# ${MOD_NAME} Configuration
enabled: true

# Worlds where the feature is disabled.
disabled-worlds: []
YAML
fi

# ─── Step 9: Update .modrinth/description.md ─────────────────────────────────

mkdir -p .modrinth
cat > .modrinth/description.md << MODRINTH_MD
# ${MOD_NAME}

${DESCRIPTION}

## Platforms

| Platform | Version |
|----------|---------|
$([ "$INCLUDE_BUKKIT"   = "true" ] && printf "| Bukkit/Spigot/Paper | %s+ |\n" "$MC_VERSION")
$([ "$INCLUDE_FABRIC"   = "true" ] && printf "| Fabric | %s |\n" "$MC_VERSION")
$([ "$INCLUDE_FORGE"    = "true" ] && printf "| Forge | %s |\n" "$MC_VERSION")
$([ "$INCLUDE_NEOFORGE" = "true" ] && printf "| NeoForge | %s |\n" "$MC_VERSION")

## Download

[GitHub Releases](https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases)
MODRINTH_MD

# ─── Step 10: Update CODEOWNERS ──────────────────────────────────────────────

if [ -f ".github/CODEOWNERS" ]; then
    SED_INPLACE "s|@yourusername|@${GITHUB_OWNER}|g" .github/CODEOWNERS
fi

# ─── Step 11: Create initial CHANGELOG entry ─────────────────────────────────

cat > CHANGELOG.md << CHANGELOG_MD
# Changelog

All notable changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - $(date +%Y-%m-%d)

### Added
- Initial release of ${MOD_NAME}
CHANGELOG_MD

# ─── Step 12: Initial git commit ─────────────────────────────────────────────

info "Creating initial git commit..."
git config user.name "${AUTHOR}" 2>/dev/null || true
git add -A
git commit -m "chore: initialise ${MOD_NAME} from mc-multiplatform-template" 2>/dev/null \
    || warn "Could not commit — run 'git commit' manually."

# ─── Done ────────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✅  Project setup complete! (${MOD_NAME})${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. ${CYAN}Verify${NC} the generated code in your IDE"
echo -e "  2. ${CYAN}Build${NC}  to confirm everything compiles:"
echo -e "     ${YELLOW}./gradlew :common:test${NC}"
$([ "$INCLUDE_BUKKIT" = "true" ] && echo "     ${YELLOW}cd bukkit   && ./gradlew build${NC}")
$([ "$INCLUDE_FABRIC" = "true" ] && echo "     ${YELLOW}cd fabric   && ./gradlew build${NC}")
$([ "$INCLUDE_FORGE"  = "true" ] && echo "     ${YELLOW}cd forge    && ./gradlew build${NC}")
$([ "$INCLUDE_NEOFORGE" = "true" ] && echo "     ${YELLOW}cd neoforge && ./gradlew build${NC}")
echo -e "  3. ${CYAN}Push${NC}   to GitHub: ${YELLOW}git push -u origin main${NC}"
echo -e "  4. ${CYAN}Set${NC}    repo secrets: ${YELLOW}MODRINTH_TOKEN${NC} and variable ${YELLOW}MODRINTH_PROJECT_ID${NC}"
echo -e "  5. ${CYAN}Replace${NC} ${YELLOW}ExampleFeature${NC} stub with your actual logic in ${YELLOW}common/${NC}"
echo ""

rm -- "$0"
