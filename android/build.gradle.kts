plugins {
    id("com.google.gms.google-services") version "4.4.3" apply false
    // id("kotlin-android") version "1.9.10" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Redirect root build dir to Flutter project build folder
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

buildscript {
    dependencies{classpath("com.google.gms:google-services:4.4.3")}
}