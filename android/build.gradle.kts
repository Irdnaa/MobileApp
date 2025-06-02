buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // 🔧 Kotlin plugin: update to 1.9.23
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
        // 🔧 Google Services plugin (for Firebase)
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}