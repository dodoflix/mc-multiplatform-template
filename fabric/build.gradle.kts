plugins {
    alias(libs.plugins.fabric.loom)
}

val modVersion: String by project
val mavenGroup: String by project
group = mavenGroup
version = modVersion

val minecraftVersion = libs.versions.minecraft.get()
val fabricLoaderVersion = libs.versions.fabric.loader.get()

base {
    archivesName.set("ModTemplate-Fabric")
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

repositories {
    maven("https://maven.fabricmc.net/")
    mavenCentral()
}

dependencies {
    minecraft(libs.minecraft)
    mappings(loom.officialMojangMappings())
    modImplementation(libs.fabric.loader)
    modImplementation(libs.fabric.api)

    implementation("me.example:modtemplate-common")
    include("me.example:modtemplate-common")
}

tasks {
    processResources {
        val props = mapOf(
            "version" to project.version,
            "minecraft_version" to minecraftVersion,
            "loader_version" to fabricLoaderVersion
        )
        inputs.properties(props)
        filesMatching("fabric.mod.json") {
            expand(props)
        }
    }
}
