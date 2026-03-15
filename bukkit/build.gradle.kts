plugins {
    `java-library`
    alias(libs.plugins.shadow)
    jacoco
}

val modVersion: String by project
val mavenGroup: String by project
group = mavenGroup
version = modVersion

base {
    archivesName.set("ModTemplate-Bukkit")
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}

jacoco {
    toolVersion = "0.8.12"
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
    maven("https://hub.spigotmc.org/nexus/content/repositories/snapshots/") {
        name = "spigotmc-repo"
    }
    maven("https://oss.sonatype.org/content/repositories/snapshots/") {
        name = "sonatype-snapshots"
    }
    mavenCentral()
}

dependencies {
    implementation("me.example:modtemplate-common")

    compileOnly(libs.spigot.api)

    testImplementation(libs.junit.jupiter)
    testImplementation(libs.junit.jupiter.params)
    testRuntimeOnly(libs.junit.platform.launcher)
    testImplementation(libs.mockito.core)
    testImplementation(libs.mockito.junit.jupiter)
    testImplementation(libs.spigot.api)
}

tasks {
    jar {
        archiveClassifier.set("slim")
    }

    shadowJar {
        archiveClassifier.set("")
        relocate("me.example.modtemplate.common", "me.example.modtemplate.bukkit.common")
        exclude("LICENSE", "LICENSE.txt", "META-INF/LICENSE", "META-INF/LICENSE.txt")
        mergeServiceFiles()
    }

    build {
        dependsOn(shadowJar)
    }

    processResources {
        val props = mapOf(
            "version" to project.version,
            "description" to "A Minecraft plugin template."
        )
        inputs.properties(props)
        filesMatching("plugin.yml") {
            expand(props)
        }
    }

    test {
        useJUnitPlatform()
        finalizedBy(jacocoTestReport)
    }

    jacocoTestReport {
        reports {
            xml.required.set(true)
            html.required.set(true)
        }
    }
}
