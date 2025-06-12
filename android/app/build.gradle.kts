plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.parking_user"

    // 1 Compile SDK version
    compileSdk = 35

    // 2 Specify the NDK version
    ndkVersion = "27.0.12077973"

    defaultConfig {
        // TODO: Specify your own unique Application ID
        applicationId = "com.example.parking_user"

        // 3 Minimum SDK version and enable MultiDex
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    compileOptions {
        // 4 Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            // Use the debug signing config for now; replace with your own for production.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // 5 Core‐library desugaring dependency
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // … any other dependencies you already had …
}
