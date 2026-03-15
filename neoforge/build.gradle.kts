plugins {
    alias(libs.plugins.neoforge.moddev)
}

val modVersion: String by project
val mavenGroup: String by project
group = mavenGroup
version = modVersion

val catalog = versionCatalogs.named("libs")
val minecraftVersion = catalog.findVersion("neoforge-mc").get().requiredVersion
val neoforgeVersion = catalog.findVersion("neoforge").get().requiredVersion

base {
    archivesName.set("ModTemplate-NeoForge")
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}

tasks.withType<JavaCompile> {
    options.encoding = "UTF-8"
}

tasks.withType<Jar> {
    from(rootDir.parentFile.resolve("LICENSE")) {
        rename { "${it}_ModTemplate" }
    }
}

neoForge {
    version = neoforgeVersion

    runs {
        create("client") {
            client()
        }
        create("server") {
            server()
        }
    }

    mods {
        create("modtemplate") {
            sourceSet(sourceSets.main.get())
        }
    }
}

repositories {
    maven("https://maven.neoforged.net/releases/")
    mavenCentral()
}

dependencies {
    implementation("me.example:modtemplate-common")
    jarJar("me.example:modtemplate-common")
}

tasks {
    processResources {
        val props = mapOf(
            "version" to project.version,
            "minecraft_version" to minecraftVersion,
            "neoforge_version" to neoforgeVersion
        )
        inputs.properties(props)
        filesMatching("META-INF/neoforge.mods.toml") {
            expand(props)
        }
    }
}
