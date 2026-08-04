import java.util.Properties

plugins {
    id("com.android.application")

    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration

    id("kotlin-android")

    // Flutter Gradle Plugin must be applied after Android and Kotlin plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ================================
// Keystore Configuration
// ================================

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

val hasReleaseKeystore =
    keystorePropertiesFile.exists() &&
    !keystoreProperties.getProperty("keyAlias").isNullOrBlank() &&
    !keystoreProperties.getProperty("keyPassword").isNullOrBlank() &&
    !keystoreProperties.getProperty("storeFile").isNullOrBlank() &&
    !keystoreProperties.getProperty("storePassword").isNullOrBlank()

android {
    namespace = "com.example.erp_management"

    compileSdk = flutter.compileSdkVersion

    ndkVersion = flutter.ndkVersion

    // ================================
    // Java Configuration
    // ================================

    compileOptions {
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // ================================
    // App Configuration
    // ================================

    defaultConfig {
        // Keep this same as your Play Store application ID
        applicationId = "com.app.schoolclub"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ================================
    // Signing Configuration
    // ================================

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")

                storeFile = rootProject.file(
                    keystoreProperties.getProperty("storeFile")
                )

                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    // ================================
    // Build Types
    // ================================

    buildTypes {

        getByName("debug") {
            // Default Android debug signing
        }

        getByName("release") {

            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                // Only fallback for local testing.
                // Don't upload a debug-signed build to Play Store.
                signingConfigs.getByName("debug")
            }

            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = false
        }
    }
}

// ================================
// Dependencies
// ================================

dependencies {

    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.4"
    )

    implementation(
        "androidx.appcompat:appcompat:1.6.1"
    )
}



flutter {
    source = "../.."
}