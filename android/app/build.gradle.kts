import groovy.json.JsonSlurper

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load environment variables from env.json
val envFile = rootProject.file("../env/keys.json")
val envConfig: Map<String, String> = if (envFile.exists()) {
    @Suppress("UNCHECKED_CAST")
    JsonSlurper().parseText(envFile.readText()) as Map<String, String>
} else {
    emptyMap()
}

fun getEnvVariable(key: String): String {
    return envConfig[key] ?: System.getenv(key) ?: ""
}

android {
    namespace = "com.example.dicoding_story"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.kodakito"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"
        testInstrumentationRunnerArguments["clearPackageData"] = "true"

        manifestPlaceholders["googleMapsApiKey"] = getEnvVariable("MAPS_APIKEY")
    }

    buildTypes {
        getByName("release") {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
            applicationIdSuffix = ".debug"
        }
    }
    flavorDimensions += "flavors"
    productFlavors {
        create("free-dev") {
            dimension = "flavors"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
        }
        create("free-prod") {
            dimension = "flavors"
        }
        create("paid-dev") {
            dimension = "flavors"
            applicationIdSuffix = ".pro.dev"
            versionNameSuffix = "-pro-dev"
        }
        create("paid-prod") {
            dimension = "flavors"
            applicationIdSuffix = ".pro"
            versionNameSuffix = "-pro"
        }
    }

    testOptions {
        execution = "ANDROIDX_TEST_ORCHESTRATOR"
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs_nio:2.1.5")
    androidTestUtil("androidx.test:orchestrator:1.5.1")
}

flutter {
    source = "../.."
}

// unnecessary but need for debugging
// tasks.register("printEnvVariables") {
//     doLast {
//         println("APP_URL: ${getEnvVariable("APP_URL")}")
//         println("MAPS_APIKEY: ${getEnvVariable("MAPS_APIKEY")}")
//     }
// }