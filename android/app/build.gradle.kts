plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
val XDAG_RELEASE_STORE_FILE = project.properties["XDAG_RELEASE_STORE_FILE"] as String
val XDAG_RELEASE_STORE_PASSWORD = project.properties["XDAG_RELEASE_STORE_PASSWORD"] as String
val XDAG_RELEASE_KEY_ALIAS = project.properties["XDAG_RELEASE_KEY_ALIAS"] as String
val XDAG_RELEASE_KEY_PASSWORD = project.properties["XDAG_RELEASE_KEY_PASSWORD"] as String

android {
    namespace = "com.xdag.io"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.xdag.io"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            // signingConfig = signingConfigs.getByName("debug")
            // signingConfig = signingConfigs.getByName("debug")
            signingConfig = signingConfigs.create("release") {
                storeFile = file(XDAG_RELEASE_STORE_FILE)
                storePassword = XDAG_RELEASE_STORE_PASSWORD
                keyAlias = XDAG_RELEASE_KEY_ALIAS
                keyPassword = XDAG_RELEASE_KEY_PASSWORD
            }
        }
    }
}

flutter {
    source = "../.."
}
