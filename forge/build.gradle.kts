plugins {
    id("net.minecraftforge.gradle") version "[6.0.16,6.2)"
    alias(libs.plugins.shadow)
}

val modVersion: String by project
val mavenGroup: String by project
group = mavenGroup
version = modVersion

val forgeVersion = libs.versions.forge.get()
require('-' in forgeVersion) { "Unexpected Forge version format (expected '<mcVersion>-<forgeVersion>'): $forgeVersion" }
val minecraftVersion = forgeVersion.substringBefore('-')

base {
    archivesName.set("ModTemplate-Forge")
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

minecraft {
    mappings("official", minecraftVersion)

    runs {
        create("client") {
            workingDirectory(project.file("run"))
            property("forge.logging.markers", "REGISTRIES")
            property("forge.logging.console.level", "debug")
            mods {
                create("modtemplate") {
                    source(sourceSets.main.get())
                }
            }
        }

        create("server") {
            workingDirectory(project.file("run"))
            property("forge.logging.markers", "REGISTRIES")
            property("forge.logging.console.level", "debug")
            mods {
                create("modtemplate") {
                    source(sourceSets.main.get())
                }
            }
        }
    }
}

repositories {
    maven("https://maven.minecraftforge.net/")
    maven("https://libraries.minecraft.net/") {
        name = "Minecraft Libraries"
        content { includeGroup("org.lwjgl") }
    }
    mavenCentral()
}

dependencies {
    minecraft(libs.forge)

    implementation("me.example:modtemplate-common")
    shadow("me.example:modtemplate-common")
}

tasks {
    processResources {
        val forgeVersionOnly = forgeVersion.split("-")[1]
        val props = mapOf(
            "version" to project.version,
            "minecraft_version" to minecraftVersion,
            "forge_version" to forgeVersionOnly
        )
        inputs.properties(props)
        filesMatching("META-INF/mods.toml") {
            expand(props)
        }
    }

    shadowJar {
        archiveClassifier.set("")
        configurations = listOf(project.configurations.getByName("shadow"))
        relocate("me.example.modtemplate.common", "me.example.modtemplate.forge.common")
        exclude("LICENSE", "LICENSE.txt", "META-INF/LICENSE", "META-INF/LICENSE.txt")
        mergeServiceFiles()
        manifest {
            attributes(
                "Specification-Title" to "ModTemplate",
                "Specification-Vendor" to "yourname",
                "Specification-Version" to "1",
                "Implementation-Title" to project.name,
                "Implementation-Version" to project.version,
                "Implementation-Vendor" to "yourname"
            )
        }
    }

    jar {
        archiveClassifier.set("slim")
    }

    build {
        dependsOn(shadowJar)
    }
}

afterEvaluate {
    tasks.findByName("reobfShadowJar")?.let { reobfTask ->
        tasks.named("shadowJar") { finalizedBy(reobfTask) }
    }
    tasks.findByName("reobfJar")?.let { reobfTask ->
        tasks.named("shadowJar") { finalizedBy(reobfTask) }
    }
}
