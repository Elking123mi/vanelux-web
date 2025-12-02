package com.example.luxury_taxi_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"getOpenAiKey" -> {
						val persona = call.argument<String>("persona") ?: CLIENT_PERSONA
						val key = if (persona == DRIVER_PERSONA) {
							BuildConfig.OPENAI_API_KEY_DRIVER
						} else {
							BuildConfig.OPENAI_API_KEY_CLIENT
						}

						if (key.isNullOrBlank()) {
							result.error("NO_KEY", "OpenAI API key not configured for $persona", null)
						} else {
							result.success(key)
						}
					}

					else -> result.notImplemented()
				}
			}
	}

	private companion object {
		const val CHANNEL_NAME = "com.vanelux/config"
		const val CLIENT_PERSONA = "client"
		const val DRIVER_PERSONA = "driver"
	}
}
