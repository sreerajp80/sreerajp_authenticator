import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "in.sreerajp.sreerajp_authenticator"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    flavorDimensions += "environment"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "in.sreerajp.sreerajp_authenticator"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            manifestPlaceholders["appName"] = "Sreeraj P Authenticator Dev"
        }
        create("prod") {
            dimension = "environment"
            manifestPlaceholders["appName"] = "Sreeraj P Authenticator"
        }
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                val storeFilePath = keystoreProperties.getProperty("storeFile")
                if (!storeFilePath.isNullOrBlank()) {
                    storeFile = file(storeFilePath)
                }
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                // Keep dev release builds usable without a release keystore.
                // Prod release tasks are blocked below unless signing is configured.
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
    applicationVariants.all {
        val variant = this
        val hasSplitOutputs = variant.outputs.size > 1
        variant.outputs
            .map { it as com.android.build.gradle.internal.api.BaseVariantOutputImpl }
            .forEach { output ->
                if (hasSplitOutputs) {
                    return@forEach
                }
                val appName = "SreerajP_Authenticator"
                val flavorName = variant.flavorName.ifBlank { "default" }
                output.outputFileName =
                    "${appName}_${flavorName}_v${variant.versionName}_${variant.versionCode}_${variant.buildType.name}.apk"
            }
    }
}

afterEvaluate {
    listOf("assembleProdRelease", "bundleProdRelease").forEach { taskName ->
        tasks.matching { it.name == taskName }.configureEach {
            doFirst {
                if (!keystorePropertiesFile.exists()) {
                    throw GradleException(
                        """
                        SIGNING REQUIRED: prod release build blocked.
                        android/key.properties was not found.
                        Configure release signing as documented in docs/flutter_build_flavors_guide.md.
                        """.trimIndent(),
                    )
                }
            }
        }
    }
}

flutter {
    source = "../.."
}
