plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.garima.midas"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.garima.midas"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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

dependencies {
    // Chainway UHF RFID SDK (com.rscja.deviceapi) — the reader on the target
    // device is a Chainway handheld, matching the reference MIDAS Android app
    // (AssignQRActivity uses com.rscja.deviceapi.RFIDWithUHFUART).
    //
    // Preferred: a local copy at app/libs/DeviceAPI_ver20231208_release.aar.
    // Fallback: reference the same aar in-place from the reference MIDAS project
    // so the build works without a manual copy. Whichever exists is used.
    val localAar = file("libs/DeviceAPI_ver20231208_release.aar")
    val referenceAar =
        file("D:/StudioFlutterAllProject/Midas/app/libs/DeviceAPI_ver20231208_release.aar")
    val chainwayAar = if (localAar.exists()) localAar else referenceAar
    implementation(files(chainwayAar))
}
