#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Path to build.gradle
const BUILD_GRADLE = path.resolve(__dirname, '../webf/android/build.gradle');

// Patch the build.gradle file
function patchBuildGradle() {
  console.log('Patching webf/android/build.gradle...');
  
  // Target content - this is what we want the file to look like
  const targetContent = `group 'com.openwebf.webf'
version '1.0'

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:7.3.0")
    }
}


allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

apply plugin: 'com.android.library'


android {
    if (project.android.hasProperty("namespace")) {
        namespace = "com.openwebf.webf"
    }

    compileSdk = 34

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    defaultConfig {
        minSdk = 21
        externalNativeBuild {
            cmake {
                arguments "-DANDROID_STL=c++_shared", "-DIS_ANDROID=TRUE"
            }
        }
    }

    // Invoke the shared CMake build with the Android Gradle Plugin.
//    externalNativeBuild {
//        cmake {
//            path = "../src/CMakeLists.txt"
//            // The default CMake version for the Android Gradle Plugin is 3.10.2.
//            // https://developer.android.com/studio/projects/install-ndk#vanilla_cmake
//            //
//            // The Flutter tooling requires that developers have CMake 3.10 or later
//            // installed. You should not increase this version, as doing so will cause
//            // the plugin to fail to compile for some customers of the plugin.
//            // version "3.10.2"
//        }
//    }

    externalNativeBuild {
        cmake {
            abiFilters 'armeabi-v7a', 'arm64-v8a'
        }
    }

    sourceSets {
        main {
            jniLibs.srcDirs = ['jniLibs']
        }
    }

    lintOptions {
        disable 'InvalidPackage'
    }
}`;

  // Write the updated content to the file
  fs.writeFileSync(BUILD_GRADLE, targetContent);
  
  console.log('build.gradle patching completed successfully.');
}

// Main function
function main() {
  try {
    patchBuildGradle();
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

main();