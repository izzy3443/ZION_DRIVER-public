plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase services
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Must be last
    id("com.google.firebase.crashlytics")  
}

android {
    namespace = "com.example.zion_driver_553"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.zion_driver_553"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // This ensures your FirebaseMessagingService can work with older versions
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // replace for production
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.firebase:firebase-messaging:23.4.1") // latest as of July 2025
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.6.1")

    // Optional but recommended for overlay services
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")

    // Multidex support
    implementation("androidx.multidex:multidex:2.0.1")
}
