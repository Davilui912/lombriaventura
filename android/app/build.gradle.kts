plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val flutterVersionCode = project.properties["flutter.versionCode"]?.toString() ?: "1"
val flutterVersionName = project.properties["flutter.versionName"]?.toString() ?: "1.0"

android {
    namespace = "com.example.lombriaventura"
    compileSdk = 36  // ✅ CAMBIADO A 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "com.example.lombriaventura"
        minSdk = flutter.minSdkVersion
        targetSdk = 36  // ✅ TAMBIÉN SUBIR targetSdk
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
