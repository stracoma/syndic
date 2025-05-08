plugins {
    id("com.android.application") version "8.7.0" apply false // Ou "com.android.library" si c'est une librairie
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false 
    id("com.google.gms.google-services") version "4.4.2" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.7.0") // Vérifiez la dernière version
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.22") // Vérifiez la version Kotlin
        classpath("com.google.gms:google-services:4.4.2") // Assurez-vous que la version correspond
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
