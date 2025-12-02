plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Apply Google Services plugin AFTER android {} block
// Do NOT put `apply(plugin = "...")` at the end with KTS; instead, use this:
apply(plugin = "com.google.gms.google-services")

android {
    namespace = "com.example.doctor_booking_app"
    compileSdk = 36 // Replace with flutter.compileSdkVersion if you have flutter reference

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.doctor_booking_app"
        minSdk = flutter.minSdkVersion // Replace with flutter.minSdkVersion
        targetSdk = 34 // Replace with flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
