package com.jiguang.jpush

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import cn.jpush.android.api.JPushInterface
import cn.jpush.android.data.JPushLocalNotification
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.*

private const val TAG = "JPushPlugin"

/**
 * 插件具体实现，和对应的FlutterEngine进行通信
 */
class JPushPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private var flutterPluginBinding: FlutterPluginBinding? = null

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "jpush")
        flutterPluginBinding = binding
        JPushCallbackDispatcher.registerPlugin(this)
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        JPushCallbackDispatcher.unregisterPlugin(this)
        flutterPluginBinding = null
        channel = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.i(TAG, call.method)
        when (call.method) {
            "getPlatformVersion" -> result.success("Android " + Build.VERSION.RELEASE)
            "setup" -> setup(call)
            "setTags" -> setTags(call, result)
            "cleanTags" -> cleanTags(result)
            "addTags" -> addTags(call, result)
            "deleteTags" -> deleteTags(call, result)
            "getAllTags" -> getAllTags(call, result)
            "setAlias" -> setAlias(call, result)
            "deleteAlias" -> deleteAlias(result)
            "stopPush" -> stopPush()
            "resumePush" -> resumePush()
            "clearAllNotifications" -> clearAllNotifications()
            "clearNotification" -> clearNotification(call)
            "getLaunchAppNotification" -> getLaunchAppNotification()
            "getRegistrationID" -> getRegistrationID(result)
            "sendLocalNotification" -> sendLocalNotification(call)
            "setBadge" -> setBadge(call, result)
            "isNotificationEnabled" -> isNotificationEnabled(result)
            "openSettingsForNotification" -> openSettingsForNotification()
            else -> result.notImplemented()
        }
    }

    private fun applicationContext(): Context? {
        return flutterPluginBinding?.applicationContext
    }

    // 主线程再返回数据
    private fun callbackOnMainThread(
        map: Map<String, Any?>?,
        result: MethodChannel.Result?,
        method: String?
    ) {
        Log.d(TAG, "runMainThread:map = $map,method =$method")
        Handler(Looper.getMainLooper()).post {
            if (result == null && method != null) {
                channel?.invokeMethod(method, map)
            } else {
                result?.success(map)
            }
        }
    }

    private fun setup(call: MethodCall) {
        Log.d(TAG, "setup :" + call.arguments)
        val map = call.arguments<HashMap<String?, Any?>?>()
        val debug = map["debug"] as? Boolean ?: false
        JPushInterface.setDebugMode(debug)
        JPushInterface.init(applicationContext()) // 初始化 JPush
        val channel = map["channel"] as? String
        JPushInterface.setChannel(applicationContext(), channel)

        //try to deal with all cache
        JPushCallbackDispatcher.onSetUpDone()
        JPushCallbackDispatcher.checkAndTryCleanCache()
    }

    private fun appendToCallbacks(result: MethodChannel.Result): Int {
        val sequence = JPushCallbackDispatcher.obtainIncrementalSequence()
        JPushCallbackDispatcher.appendToCallbacks(this, sequence, result)
        return sequence
    }

    private fun setTags(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "setTags：${call.arguments}")
        val tagList = call.arguments<List<String>>()
        val tags: Set<String> = HashSet(tagList)
        val sequence = appendToCallbacks(result)
        JPushInterface.setTags(applicationContext(), sequence, tags)
    }

    private fun cleanTags(result: MethodChannel.Result) {
        Log.d(TAG, "cleanTags:")
        val sequence = appendToCallbacks(result)
        JPushInterface.cleanTags(applicationContext(), sequence)
    }

    private fun addTags(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "addTags: ${call.arguments}")
        val tagList = call.arguments<List<String>>()
        val tags: Set<String> = HashSet(tagList)
        val sequence = appendToCallbacks(result)
        JPushInterface.addTags(applicationContext(), sequence, tags)
    }

    private fun deleteTags(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "deleteTags： ${call.arguments}")
        val tagList = call.arguments<List<String>>()
        val tags: Set<String> = HashSet(tagList)
        val sequence = appendToCallbacks(result)
        JPushInterface.deleteTags(applicationContext(), sequence, tags)
    }

    private fun getAllTags(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "getAllTags： ${call.arguments}")
        val sequence = appendToCallbacks(result)
        JPushInterface.getAllTags(applicationContext(), sequence)
    }

    private fun setAlias(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "setAlias: " + call.arguments)
        val alias = call.arguments<String>()
        val sequence = appendToCallbacks(result)
        JPushInterface.setAlias(applicationContext(), sequence, alias)
    }

    private fun deleteAlias(result: MethodChannel.Result) {
        Log.d(TAG, "deleteAlias:")
        val sequence = appendToCallbacks(result)
        JPushInterface.deleteAlias(applicationContext(), sequence)
    }

    private fun stopPush() {
        Log.d(TAG, "stopPush:")
        JPushInterface.stopPush(applicationContext())
    }

    private fun resumePush() {
        Log.d(TAG, "resumePush:")
        JPushInterface.resumePush(applicationContext())
    }

    private fun clearAllNotifications() {
        Log.d(TAG, "clearAllNotifications: ")
        JPushInterface.clearAllNotifications(applicationContext())
    }

    private fun clearNotification(call: MethodCall) {
        Log.d(TAG, "clearNotification: ${call.arguments}")
        val id = call.arguments
        id?.let {
            JPushInterface.clearNotificationById(applicationContext(), id as Int)
        }
    }

    private fun getLaunchAppNotification() {
        Log.d(TAG, "getLaunchAppNotification")
    }

    private fun getRegistrationID(result: MethodChannel.Result) {
        Log.d(TAG, "getRegistrationID ")
        val rid = JPushInterface.getRegistrationID(applicationContext())
        if (rid.isNullOrEmpty()) {
            JPushCallbackDispatcher.appendToObtainRidCache(this, result)
        } else {
            result.success(rid)
        }
    }

    private fun sendLocalNotification(call: MethodCall) {
        Log.d(TAG, "sendLocalNotification: " + call.arguments)
        try {
            val map = call.arguments<HashMap<String?, Any?>>()
            val ln = JPushLocalNotification()
            ln.builderId = map["buildId"] as? Long ?: -1L
            ln.notificationId = map["id"] as? Long ?: -1L
            ln.title = map["title"] as? String
            ln.content = map["content"] as? String
            val extra = map["extra"] as? HashMap<String?, Any?>
            if (extra != null) {
                val json = JSONObject(extra)
                ln.extras = json.toString()
            }
            val date = map["fireTime"] as Long
            ln.broadcastTime = date
            JPushInterface.addLocalNotification(
                applicationContext(),
                ln
            )
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun setBadge(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "setBadge: " + call.arguments)
        val map = call.arguments<HashMap<String?, Any?>>()
        val numObject = map["badge"]
        if (numObject != null) {
            val num = numObject as Int
            JPushInterface.setBadgeNumber(applicationContext(), num)
            result.success(true)
        }
    }

    private fun isNotificationEnabled(result: MethodChannel.Result) {
        Log.d(TAG, "isNotificationEnabled: ")
        val isEnabled = JPushInterface.isNotificationEnabled(applicationContext())
        callbackOnMainThread(mapOf(Pair("isEnabled", isEnabled == 1)), result, null)
    }

    private fun openSettingsForNotification() {
        Log.d(TAG, "openSettingsForNotification: ")
        JPushInterface.goToAppNotificationSettings(applicationContext())
    }

    internal fun onMessageReceive(message: Map<String, Any?>) {
        callbackOnMainThread(message, null, "onReceiveMessage")
    }

    internal fun onNotificationOpen(notification: Map<String, Any?>) {
        callbackOnMainThread(notification, null, "onOpenNotification")
    }

    internal fun onNotificationReceive(notification: Map<String, Any?>) {
        callbackOnMainThread(notification, null, "onReceiveNotification")
    }

    internal fun onNotificationSettingsCheck(settingStatus: Map<String, Boolean>) {
        callbackOnMainThread(settingStatus, null, "onReceiveNotificationAuthorization")
    }
}