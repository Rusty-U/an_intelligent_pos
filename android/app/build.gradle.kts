plugins {
    id("kotlin-android")
    id("com.android.application")
    id("com.google.gms.google-services")
    // Flutter Gradle plugin must be applied after Android and Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.company.an_intelligent_pos"

    compileSdk = 36

    defaultConfig {
    applicationId = "com.company.an_intelligent_pos"
    minSdk = flutter.minSdkVersion.toInt()
    targetSdk = flutter.targetSdkVersion.toInt()
    versionCode = 1
    versionName = "1.0"
}
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
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

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.1.0"))
    implementation("com.google.firebase:firebase-analytics")
}
