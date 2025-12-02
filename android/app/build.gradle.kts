import java.io.File
import java.util.Base64
import java.util.Properties
import kotlin.text.Charsets

fun String.escapeForBuildConfig(): String =
    this.replace("\\", "\\\\").replace("\"", "\\\"")

val localProperties = Properties()
val localPropertiesFile = File(rootProject.projectDir, "local.properties")
if (localPropertiesFile.exists() && localPropertiesFile.isFile) {
    localPropertiesFile.inputStream().use(localProperties::load)
}

val mapsApiKey = (
    localProperties.getProperty("MAPS_API_KEY") ?: System.getenv("MAPS_API_KEY")
) ?: "CHANGE_ME"

val openAiClientKey = (
    localProperties.getProperty("OPENAI_API_KEY_CLIENT") ?: System.getenv("OPENAI_API_KEY_CLIENT")
) ?: ""

val openAiDriverKey = (
    localProperties.getProperty("OPENAI_API_KEY_DRIVER") ?: System.getenv("OPENAI_API_KEY_DRIVER")
) ?: ""

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.luxury_taxi_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    buildFeatures {
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.luxury_taxi_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["mapsApiKey"] = mapsApiKey

        buildConfigField(
            "String",
            "OPENAI_API_KEY_CLIENT",
            "\"${openAiClientKey.escapeForBuildConfig()}\"",
        )

        buildConfigField(
            "String",
            "OPENAI_API_KEY_DRIVER",
            "\"${openAiDriverKey.escapeForBuildConfig()}\"",
        )
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

val existingDartDefines = (project.findProperty("dart-defines") as String?)
    ?.split(",")
    ?.filter { it.isNotBlank() }
    ?.toMutableList()
    ?: mutableListOf()

fun encodeForDartDefine(value: String): String =
    Base64.getEncoder().encodeToString(value.toByteArray(Charsets.UTF_8))

if (openAiClientKey.isNotEmpty()) {
    val encodedClientDefine = encodeForDartDefine("OPENAI_API_KEY_CLIENT=$openAiClientKey")
    if (!existingDartDefines.contains(encodedClientDefine)) {
        existingDartDefines.add(encodedClientDefine)
    }
}

if (openAiDriverKey.isNotEmpty()) {
    val encodedDriverDefine = encodeForDartDefine("OPENAI_API_KEY_DRIVER=$openAiDriverKey")
    if (!existingDartDefines.contains(encodedDriverDefine)) {
        existingDartDefines.add(encodedDriverDefine)
    }
}

if (existingDartDefines.isNotEmpty()) {
    project.extensions.extraProperties["dart-defines"] =
        existingDartDefines.joinToString(",")
}

flutter {
    source = "../.."
}
