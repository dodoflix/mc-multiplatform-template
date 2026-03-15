pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
    }
}

rootProject.name = "ModTemplate"

// common is a regular subproject — shared logic and unit tests
include("common")

// Platform modules are independent builds, each with their own Gradle wrapper:
//   bukkit, forge, neoforge → gradle-8.14.3
//   fabric                  → gradle-9.x
// Run them from their own directories: e.g. `cd fabric && ./gradlew build`
