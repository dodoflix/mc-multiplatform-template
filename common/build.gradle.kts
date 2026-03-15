plugins {
    java
    jacoco
}

val versionCatalog = extensions.getByType<VersionCatalogsExtension>().named("libs")

dependencies {
    // Testing
    testImplementation(versionCatalog.findLibrary("junit-jupiter").get())
    testImplementation(versionCatalog.findLibrary("junit-jupiter-params").get())
    testRuntimeOnly(versionCatalog.findLibrary("junit-platform-launcher").get())
    testImplementation(versionCatalog.findLibrary("mockito-core").get())
    testImplementation(versionCatalog.findLibrary("mockito-junit-jupiter").get())
}

tasks.test {
    useJUnitPlatform()
}
