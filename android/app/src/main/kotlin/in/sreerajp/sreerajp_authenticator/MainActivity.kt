package `in`.sreerajp.sreerajp_authenticator

import android.content.ClipData
import android.content.ClipboardManager
import android.os.PersistableBundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "sreerajp_authenticator/device_state"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBootCount" -> {
                    try {
                        result.success(
                            Settings.Global.getInt(
                                contentResolver,
                                Settings.Global.BOOT_COUNT
                            )
                        )
                    } catch (_: Exception) {
                        result.success(null)
                    }
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "sreerajp_authenticator/clipboard"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setSensitiveText" -> {
                    val text = call.arguments as? String
                    if (text == null) {
                        result.error("invalid_argument", "Text is required", null)
                    } else {
                        val clip = ClipData.newPlainText("", text)
                        // Android 13+ hides this text in its clipboard preview.
                        clip.description.extras = PersistableBundle().apply {
                            putBoolean("android.content.extra.IS_SENSITIVE", true)
                        }
                        getSystemService(ClipboardManager::class.java).setPrimaryClip(clip)
                        result.success(null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}
