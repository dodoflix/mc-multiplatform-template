#!/usr/bin/env bash
# setup.sh — Initialises a new project from the mc-multiplatform-template.
# Run once after cloning: bash setup.sh
# It replaces all placeholder values, renames files and directories, then removes itself.

set -e

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
    local default="$2"
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

to_pascal_case() {
    # "my-mod-name" → "MyModName"
    echo "$1" | sed 's/-\([a-z]\)/\U\1/g; s/^\([a-z]\)/\U\1/'
}

to_lower_no_sep() {
    # "MyMod" or "my-mod" → "mymod"
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d '-_'
}

# ─── Gather inputs ────────────────────────────────────────────────────────────

echo -e "Answer the following questions to configure your project."
echo -e "Press ${CYAN}Enter${NC} to accept the default shown in brackets.\n"

MOD_NAME=$(read_input "Mod/plugin display name (PascalCase)" "MyMod")
MOD_ID=$(read_input "Mod ID (lowercase, no spaces/dashes)" "$(to_lower_no_sep "$MOD_NAME")")
MOD_ID_KEBAB=$(read_input "Modrinth/kebab-case slug (e.g. my-mod)" "$(echo "$MOD_ID" | sed 's/\([A-Z]\)/-\L\1/g; s/^-//')")
PACKAGE=$(read_input "Java base package (e.g. com.yourname)" "me.example")
AUTHOR=$(read_input "Author name" "yourname")
GITHUB_OWNER=$(read_input "GitHub username/org" "yourusername")
GITHUB_REPO=$(read_input "GitHub repository name" "$MOD_NAME")
DESCRIPTION=$(read_input "Short description" "A Minecraft mod.")
MC_VERSION=$(read_input "Minecraft version" "1.21.11")
JAVA_VERSION=$(read_input "Java version" "21")

# Derived values
PACKAGE_PATH="${PACKAGE//./\/}"      # me.example → me/example
PACKAGE_PATH_OLD="me/example"
PACKAGE_OLD="me.example"
MOD_ID_OLD="modtemplate"
MOD_NAME_OLD="ModTemplate"

echo ""
echo -e "${CYAN}── Summary ──────────────────────────────────────────${NC}"
echo -e "  Mod name:      ${GREEN}${MOD_NAME}${NC}"
echo -e "  Mod ID:        ${GREEN}${MOD_ID}${NC}"
echo -e "  Slug:          ${GREEN}${MOD_ID_KEBAB}${NC}"
echo -e "  Package:       ${GREEN}${PACKAGE}.${MOD_ID}${NC}"
echo -e "  Author:        ${GREEN}${AUTHOR}${NC}"
echo -e "  GitHub:        ${GREEN}${GITHUB_OWNER}/${GITHUB_REPO}${NC}"
echo -e "  Description:   ${GREEN}${DESCRIPTION}${NC}"
echo -e "  MC version:    ${GREEN}${MC_VERSION}${NC}"
echo -e "  Java version:  ${GREEN}${JAVA_VERSION}${NC}"
echo ""

read -rp "$(echo -e "${YELLOW}?${NC} Proceed? [Y/n]: ")" confirm
[[ "$confirm" =~ ^[Nn] ]] && { info "Aborted."; exit 0; }
echo ""

# ─── Step 1: Replace tokens in all text files ────────────────────────────────

info "Replacing placeholder tokens in all files..."

FILES=$(find . \
    ! -path './.git/*' \
    ! -path './setup.sh' \
    ! -name '*.jar' \
    ! -name '*.class' \
    ! -name '*.png' \
    ! -name '*.ico' \
    -type f)

replace_in_file() {
    local file="$1"
    sed -i \
        -e "s|${PACKAGE_OLD}/${MOD_ID_OLD}|${PACKAGE_PATH}/${MOD_ID}|g" \
        -e "s|${PACKAGE_OLD}\.${MOD_ID_OLD}|${PACKAGE}.${MOD_ID}|g" \
        -e "s|${PACKAGE_OLD}|${PACKAGE}|g" \
        -e "s|${MOD_NAME_OLD}|${MOD_NAME}|g" \
        -e "s|${MOD_ID_OLD}|${MOD_ID}|g" \
        -e "s|yourusername/YourRepo|${GITHUB_OWNER}/${GITHUB_REPO}|g" \
        -e "s|yourusername|${GITHUB_OWNER}|g" \
        -e "s|YourRepo|${GITHUB_REPO}|g" \
        -e "s|yourname|${AUTHOR}|g" \
        -e "s|A Minecraft mod template\.|${DESCRIPTION}|g" \
        -e "s|A Minecraft plugin template\.|${DESCRIPTION}|g" \
        "$file"
}

echo "$FILES" | while read -r f; do
    replace_in_file "$f"
done

success "Token replacement complete."

# ─── Step 2: Rename Java source directories ──────────────────────────────────

info "Renaming source directories..."

rename_src_dir() {
    local platform="$1"
    local old_path="${platform}/src/main/java/${PACKAGE_PATH_OLD}/${MOD_ID_OLD}"
    local new_path="${platform}/src/main/java/${PACKAGE_PATH}/${MOD_ID}"

    if [ -d "$old_path" ]; then
        mkdir -p "$(dirname "$new_path")"
        mv "$old_path" "$new_path"
        # Remove leftover empty dirs
        find "${platform}/src/main/java/${PACKAGE_PATH_OLD}" -empty -type d -delete 2>/dev/null || true
    fi
}

rename_src_dir "common"
rename_src_dir "bukkit"
rename_src_dir "fabric"
rename_src_dir "forge"
rename_src_dir "neoforge"

# Rename test directories too
for platform in common bukkit; do
    OLD="$platform/src/test/java/${PACKAGE_PATH_OLD}/${MOD_ID_OLD}"
    NEW="$platform/src/test/java/${PACKAGE_PATH}/${MOD_ID}"
    if [ -d "$OLD" ]; then
        mkdir -p "$(dirname "$NEW")"
        mv "$OLD" "$NEW"
        find "$platform/src/test/java/${PACKAGE_PATH_OLD}" -empty -type d -delete 2>/dev/null || true
    fi
done

success "Source directories renamed."

# ─── Step 3: Rename Java class files ─────────────────────────────────────────

info "Renaming Java source files..."

rename_java_files() {
    find . ! -path './.git/*' -name "*.java" -o -name "*.kt" | while read -r f; do
        DIR=$(dirname "$f")
        BASE=$(basename "$f")
        NEW_BASE="${BASE//${MOD_NAME_OLD}/${MOD_NAME}}"
        if [ "$BASE" != "$NEW_BASE" ]; then
            mv "$f" "$DIR/$NEW_BASE"
        fi
    done
}

rename_java_files
success "Java files renamed."

# ─── Step 4: Rename resource files ───────────────────────────────────────────

info "Renaming resource files..."

# Rename mixins JSON
for f in $(find . ! -path './.git/*' -name "${MOD_ID_OLD}.mixins.json"); do
    DIR=$(dirname "$f")
    mv "$f" "$DIR/${MOD_ID}.mixins.json"
done

success "Resource files renamed."

# ─── Step 5: Update gradle.properties with MC version ────────────────────────

info "Updating Minecraft version in libs.versions.toml..."
sed -i "s|^minecraft = \".*\"|minecraft = \"${MC_VERSION}\"|g" gradle/libs.versions.toml
sed -i "s|^neoforge-mc = \".*\"|neoforge-mc = \"${MC_VERSION}\"|g" gradle/libs.versions.toml

info "Updating Java version in build.gradle.kts files..."
for f in build.gradle.kts common/build.gradle.kts bukkit/build.gradle.kts fabric/build.gradle.kts forge/build.gradle.kts neoforge/build.gradle.kts; do
    [ -f "$f" ] && sed -i "s|JavaLanguageVersion.of([0-9]*)|JavaLanguageVersion.of(${JAVA_VERSION})|g" "$f"
done

for f in gradle.properties */gradle.properties; do
    [ -f "$f" ] && sed -i "s|javaVersion=.*|javaVersion=${JAVA_VERSION}|g" "$f"
done

# ─── Step 6: Update .github/workflows/ci.yml caller ─────────────────────────

info "Updating CI/CD caller workflows..."
sed -i \
    -e "s|mod-name: ${MOD_NAME_OLD}|mod-name: ${MOD_NAME}|g" \
    -e "s|mod-id: ${MOD_ID_OLD}|mod-id: ${MOD_ID}|g" \
    -e "s|java-version: '21'|java-version: '${JAVA_VERSION}'|g" \
    -e "s|\"21\"|\"${JAVA_VERSION}\"|g" \
    .github/workflows/ci.yml \
    .github/workflows/release.yml 2>/dev/null || true

# ─── Step 7: Update settings.gradle.kts project name ────────────────────────

sed -i "s|rootProject.name = \"ModTemplate\"|rootProject.name = \"${MOD_NAME}\"|g" settings.gradle.kts

# ─── Step 8: Create default config.yml for Bukkit ────────────────────────────

mkdir -p bukkit/src/main/resources
cat > bukkit/src/main/resources/config.yml << YAML
# ${MOD_NAME} Configuration
enabled: true

# Worlds where the feature is disabled.
# Add world names to this list to exclude them.
disabled-worlds: []
YAML

# ─── Step 9: Create .modrinth/description.md ─────────────────────────────────

cat > .modrinth/description.md << MD
# ${MOD_NAME}

${DESCRIPTION}

## Platforms

| Platform | Version |
|----------|---------|
| Bukkit/Spigot/Paper | ${MC_VERSION}+ |
| Fabric | ${MC_VERSION} |
| Forge | ${MC_VERSION} |
| NeoForge | ${MC_VERSION} |

## Download

[GitHub Releases](https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases)
MD

# ─── Step 10: Initial git commit ─────────────────────────────────────────────

info "Creating initial git commit..."
git config user.name "$AUTHOR" 2>/dev/null || true
git add -A
git commit -m "chore: initialise project from mc-multiplatform-template" 2>/dev/null || warn "Could not commit — run git commit manually."

# ─── Done ────────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✅  Project setup complete!         ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. ${CYAN}Verify${NC} the generated code in your IDE"
echo -e "  2. ${CYAN}Build${NC}  to confirm everything compiles:"
echo -e "     ${YELLOW}./gradlew :common:test${NC}"
echo -e "     ${YELLOW}cd bukkit && ./gradlew build${NC}"
echo -e "  3. ${CYAN}Push${NC}   to GitHub and set ${YELLOW}MODRINTH_TOKEN${NC} secret"
echo -e "  4. ${CYAN}Replace${NC} the stub ExampleFeature with your actual logic"
echo ""

# Remove this script
rm -- "$0"
