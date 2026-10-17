package com.example.greenroots

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "greenroots/tree_storage")
            .setMethodCallHandler { call, result ->
                try {
                    // Read the same Android preference file and key used by
                    // the original shared_preferences legacy API.
                    val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                    val key = "flutter.trees_v1"
                    when (call.method) {
                        "readTrees" -> result.success(prefs.getString(key, null))
                        "writeTrees" -> {
                            val value = call.argument<String>("value")
                            if (value == null) {
                                result.error("BAD_ARGUMENT", "Missing tree data", null)
                            } else {
                                result.success(prefs.edit().putString(key, value).commit())
                            }
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.error("STORAGE_ERROR", e.message ?: "Unknown storage error", null)
                }
            }
    }
}
