import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing. Values come from (first match wins):
//   1. environment: KAL_ROUTE_KEYSTORE_PATH, KAL_ROUTE_KEYSTORE_PASSWORD,
//      KAL_ROUTE_KEY_ALIAS, KAL_ROUTE_KEY_PASSWORD   (used by CI)
//   2. android/key.properties: storeFile, storePassword, keyAlias, keyPassword
//      (local; git-ignored, storeFile relative to android/)
// Without either, local release builds fall back to the debug key so
// `flutter run --release` keeps working. CI release builds set
// KAL_ROUTE_REQUIRE_RELEASE_SIGNING=true so a missing key fails the build
// instead of publishing a debug-signed app.
val keyProps = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) FileInputStream(f).use { load(it) }
}
fun signingValue(env: String, prop: String): String? =
    System.getenv(env)?.takeIf { it.isNotBlank() } ?: keyProps.getProperty(prop)?.takeIf { it.isNotBlank() }

val releaseStoreFile = signingValue("KAL_ROUTE_KEYSTORE_PATH", "storeFile")?.let { rootProject.file(it) }
val releaseStorePassword = signingValue("KAL_ROUTE_KEYSTORE_PASSWORD", "storePassword")
val releaseKeyAlias = signingValue("KAL_ROUTE_KEY_ALIAS", "keyAlias")
val releaseKeyPassword = signingValue("KAL_ROUTE_KEY_PASSWORD", "keyPassword")
val hasReleaseSigning = releaseStoreFile?.exists() == true &&
    releaseStorePassword != null && releaseKeyAlias != null && releaseKeyPassword != null
val requireReleaseSigning = System.getenv("KAL_ROUTE_REQUIRE_RELEASE_SIGNING") == "true"
if (requireReleaseSigning && !hasReleaseSigning) {
    throw GradleException("KAL_ROUTE_REQUIRE_RELEASE_SIGNING=true but the release keystore/passwords are missing")
}

android {
    namespace = "com.abhranil.commute_planner"
    compileSdk = 37 // flutter_local_notifications 23 + androidx.core 1.19 need API 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.abhranil.commute_planner"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = releaseStoreFile
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                logger.warn("kal-route: no release keystore configured, signing release build with the debug key")
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
