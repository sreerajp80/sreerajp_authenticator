package `in`.sreerajp.sreerajp_authenticator

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
    }
}
