import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "me.mansurnadim.utilities"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    val localProperties = Properties()
    localProperties.load(FileInputStream(rootProject.file("local.properties")))

    var googleMapsApiKey: String? = localProperties.getProperty("googleMapsApiKey")

    if (googleMapsApiKey == null) {
        // Fallback for CI/CD environments or if local.properties is missing
        googleMapsApiKey = System.getenv("GOOGLE_MAPS_API_KEY_ENVIRONMENT_VARIABLE")
    }

    android {
        defaultConfig {
            applicationId = "me.mansurnadim.utilities"
            minSdk = 24
            targetSdk = flutter.targetSdkVersion
            versionCode = flutter.versionCode
            versionName = flutter.versionName

            manifestPlaceholders.put("googleMapsApiKey", googleMapsApiKey ?: "")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
