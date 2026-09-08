package com.example.ebooking

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCAL_CONFIG_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    GOOGLE_API_KEY -> result.success(BuildConfig.GOOGLE_API_KEY)
                    else -> result.notImplemented()
                }
            }
    }

    private companion object {
        const val LOCAL_CONFIG_CHANNEL = "ebooking/local_config"
        const val GOOGLE_API_KEY = "googleApiKey"
    }
}
