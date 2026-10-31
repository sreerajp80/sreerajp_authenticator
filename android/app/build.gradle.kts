import java.io.File
import java.io.FileInputStream
import java.time.LocalDate
import java.util.Properties
import javax.inject.Inject
import org.gradle.api.GradleException
import org.gradle.process.ExecOperations
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    // Kotlin is compiled by AGP itself (android.builtInKotlin=true in gradle.properties).
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    FileInputStream(localPropertiesFile).use(localProperties::load)
}

val flutterSdkPath = localProperties.getProperty("flutter.sdk")
    ?: System.getenv("FLUTTER_ROOT")
    ?: throw GradleException(
        "Flutter SDK path not found. Set flutter.sdk in android\\local.properties or FLUTTER_ROOT."
    )

val isWindowsHost = System.getProperty("os.name").startsWith("Windows", ignoreCase = true)
val dartExecutable = File(
    flutterSdkPath,
    if (isWindowsHost) "bin\\dart.bat" else "bin/dart",
)
val projectRootDir = rootProject.projectDir.parentFile

// Gradle 9 removed project.exec; ExecOperations is the supported replacement.
interface InjectedExecOps {
    @get:Inject val execOps: ExecOperations
}

val generateBuildMetadata = tasks.register("generateBuildMetadata") {
    group = "build setup"
    description = "Generates About-screen build metadata before Android builds."

    inputs.file(projectRootDir.resolve("pubspec.yaml"))
    inputs.file(projectRootDir.resolve("tool/generate_build_date.dart"))
    inputs.property("metadataBuildDate", LocalDate.now().toString())
    outputs.file(projectRootDir.resolve("lib/utils/build_date.g.dart"))

    val injected = project.objects.newInstance<InjectedExecOps>()

    doLast {
        if (!dartExecutable.exists()) {
            throw GradleException(
                "Could not find Dart executable at ${dartExecutable.absolutePath}. " +
                    "Check android\\local.properties flutter.sdk or FLUTTER_ROOT."
            )
        }

        injected.execOps.exec {
            workingDir = projectRootDir
            commandLine(dartExecutable.absolutePath, "run", "tool/generate_build_date.dart")
        }
    }
}

tasks.named("preBuild") {
    dependsOn(generateBuildMetadata)
}

tasks.matching { task ->
    task.name.startsWith("compileFlutterBuild")
}.configureEach {
    dependsOn(generateBuildMetadata)
}

android {
    namespace = "in.sreerajp.sreerajp_authenticator"
    // permission_handler 13 needs 37; Flutter's default is still 36.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion
    flavorDimensions += "environment"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "in.sreerajp.sreerajp_authenticator"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // minSdk 29 (Android 10) is recorded in docs/PROJECT_PROFILE.md §3.
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
        }
        create("prod") {
            dimension = "environment"
        }
    }

    // Keep every language in the App Bundle: the in-app language picker needs
    // them even when the device language is English (engineering standard §8.1).
    bundle {
        language {
            enableSplit = false
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
                        Configure release signing as documented in docs/guidelines/flutter_build_flavors_guide.md.
                        """.trimIndent(),
                    )
                }
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17) // match compileOptions in android { }
    }
}

flutter {
    source = "../.."
}
