package com.creditchek.approval_flutter

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
// Imports from CreditChek Approval Android SDK
import com.creditchek.approval_android.CreditChekApproval
import com.creditchek.approval_android.core.session.ApprovalConfig
import com.creditchek.approval_android.core.session.AUserData
import com.creditchek.approval_android.core.session.SessionResult

/** ApprovalFlutterPlugin */
class ApprovalFlutterPlugin :
    FlutterPlugin,
    MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null

    companion object {
        private const val CHANNEL_NAME = "approval_flutter"
        private const val METHOD_START_VERIFICATION = "startVerification"
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            METHOD_START_VERIFICATION -> {
                val currentActivity = activity
                if (currentActivity == null) {
                    result.error(
                        "NO_ACTIVITY",
                        "Cannot launch verification flow: Activity is null or in background",
                        null
                    )
                    return
                }
                // 1. Extract Public Key
                val publicKey = call.argument<String>("publicKey") ?: ""
                if (publicKey.isBlank()) {
                    result.error(
                        "INVALID_CONFIG",
                        "publicKey is required and cannot be blank",
                        null
                    )
                    return
                }

                // 2. Extract Session ID
                val sessionId = call.argument<String>("sessionId") ?: ""
                if (sessionId.isBlank()) {
                    result.error(
                        "INVALID_CONFIG",
                        "sessionId is required and cannot be blank",
                        null
                    )
                    return
                }

                // 3. Extract Widget ID
                val widgetId = call.argument<String>("widgetId") ?: ""
                if (widgetId.isBlank()) {
                    result.error(
                        "INVALID_CONFIG",
                        "widgetId is required and cannot be blank",
                        null
                    )
                    return
                }

                // 4. Extract Optional User Pre-fill Data
                val userMap = call.argument<Map<String, Any?>>("userData")
                val userData = if (userMap != null) {
                    AUserData(
                        firstName = userMap["firstName"] as? String ?: "",
                        lastName = userMap["lastName"] as? String ?: "",
                        bvn = userMap["bvn"] as? String ?: "",
                        nin = userMap["nin"] as? String ?: "",
                        email = userMap["email"] as? String ?: "",
                        dob = (userMap["dob"] as? String) ?: (userMap["dateOfBirth"] as? String),
                        phone = userMap["phone"] as? String
                    )
                } else null

                // 5. Construct SDK Config (Backend dynamically provides environment, order, and branding)
                val config = ApprovalConfig(
                    publicKey = publicKey,
                    userData = userData,
                    sessionId = sessionId,
                    widgetId = widgetId
                )

                // 6. Start Verification Flow
                CreditChekApproval.start(
                    context = currentActivity,
                    config = config
                ) { sessionResult ->
                    when (sessionResult) {
                        is SessionResult.Success -> {
                            result.success(
                                mapOf(
                                    "status" to "success",
                                    "sessionId" to sessionResult.sessionId,
                                    "message" to sessionResult.message
                                )
                            )
                        }
                        is SessionResult.Cancelled -> {
                            result.success(
                                mapOf(
                                    "status" to "cancelled"
                                )
                            )
                        }
                        is SessionResult.Error -> {
                            result.success(
                                mapOf(
                                    "status" to "error",
                                    "code" to sessionResult.code,
                                    "message" to sessionResult.message
                                )
                            )
                        }
                    }
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }

    // --- ActivityAware Callbacks ---
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }
    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }
    override fun onDetachedFromActivity() {
        activity = null
    }
}
