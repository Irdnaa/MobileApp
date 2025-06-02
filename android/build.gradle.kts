buildscript {
    repositories {
        google()
        mavenCentral()
    }
<<<<<<< HEAD

    dependencies {
        // 🔧 Kotlin plugin: update to 1.9.23
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")

        // 🔧 Google Services plugin (for Firebase)
=======
    dependencies {
        classpath("com.android.tools.build:gradle:8.4.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.10")
>>>>>>> origin/main
        classpath("com.google.gms:google-services:4.4.2")
    }
}



<<<<<<< HEAD
=======


>>>>>>> origin/main
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
