package com.jiguang.jpush

import android.os.Handler
import android.os.Looper
import android.util.Log
import cn.jpush.android.api.JPushMessage
import cn.jpush.android.service.JPushMessageReceiver
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicInteger

private const val TAG = "JPushCallbackDispatcher"

enum class JPushMessageOperateType {
    TAG,
    ALIAS,
}

fun JPushMessage.obtainOperatedProperty(type: JPushMessageOperateType): Any {
    return when (type) {
        JPushMessageOperateType.TAG -> tags?.toList() ?: emptyList<String>()
        JPushMessageOperateType.ALIAS -> alias ?: ""
    }
}

/**
 * 维护不同FlutterEngine绑定产生的[JPushPlugin]的实例，并和[JPushMessageReceiver]带来的回调建立联系
 * 维护registrationId的回调缓存
 * 维护各种基于sequence和[MethodChannel.Result]的[JPushMessage]相关回调
 * 基于官方插件，因为onNotificationOpen必须基于setUp之后，维护缓存等待回调
 */
object JPushCallbackDispatcher {
    private val jPushPlugins: MutableSet<JPushPlugin> = HashSet()
    private val openNotificationCache: MutableList<Map<String, Any?>> = ArrayList()
    private val obtainRidCache: MutableList<Pair<JPushPlugin, MethodChannel.Result>> = ArrayList()
    private val callbacks: HashMap<Int, Pair<JPushPlugin, MethodChannel.Result>> = HashMap()
    private var callbackSequence: AtomicInteger = AtomicInteger(0)
    private var isSetUpDone = false
    private var registrationId: String? = null

    //添加jPushPlugin的实例
    internal fun registerPlugin(jPushPlugin: JPushPlugin) {
        runOnMainThread { jPushPlugins.add(jPushPlugin) }
    }

    //移除和jPushPlugin，以及绑定的Result相关回调
    internal fun unregisterPlugin(jPushPlugin: JPushPlugin) {
        runOnMainThread {
            jPushPlugins.remove(jPushPlugin)

            val iteratorRid = obtainRidCache.iterator()
            while (iteratorRid.hasNext()) {
                if (iteratorRid.next().first === jPushPlugin) {
                    iteratorRid.remove()
                }
            }

            val iteratorCallback = callbacks.iterator()
            while (iteratorCallback.hasNext()) {
                if (iteratorCallback.next().value.first === jPushPlugin) {
                    iteratorCallback.remove()
                }
            }
        }
    }

    private fun runOnMainThread(runnable: Runnable) {
        Handler(Looper.getMainLooper()).post(runnable)
    }

    internal fun onSetUpDone() {
        runOnMainThread { isSetUpDone = true }
    }

    internal fun obtainIncrementalSequence(): Int {
        return callbackSequence.incrementAndGet()
    }

    internal fun appendToObtainRidCache(
        jPushPlugin: JPushPlugin,
        obtainRidResult: MethodChannel.Result
    ) {
        runOnMainThread { obtainRidCache.add(Pair(jPushPlugin, obtainRidResult)) }
    }

    internal fun appendToCallbacks(
        jPushPlugin: JPushPlugin,
        seq: Int,
        result: MethodChannel.Result
    ) {
        runOnMainThread { callbacks[seq] = Pair(jPushPlugin, result) }
    }

    internal fun onMessageReceive(message: String?, extras: Map<String, Any?>?) {
        runOnMainThread {
            Log.d(TAG, "transmitMessageReceive\nmessage = $message\nextras=$extras")
            val msg: MutableMap<String, Any?> = java.util.HashMap()
            msg["message"] = message
            msg["extras"] = extras

            for (jPushPlugin in jPushPlugins) {
                jPushPlugin.onMessageReceive(msg)
            }
        }
    }

    internal fun onNotificationOpen(title: String?, alert: String?, extras: Map<String, Any?>?) {
        runOnMainThread {
            val notification =
                mapOf(Pair("title", title), Pair("alert", alert), Pair("extras", extras))
            openNotificationCache.add(notification)
            checkAndTryCleanOpenNotificationCache()
        }
    }

    internal fun onNotificationReceive(title: String?, alert: String?, extras: Map<String, Any?>?) =
        runOnMainThread {
            val notification =
                mapOf(Pair("title", title), Pair("alert", alert), Pair("extras", extras))
            for (jPushPlugin in jPushPlugins) {
                jPushPlugin.onNotificationReceive(notification)
            }
        }

    internal fun onRegistrationIdReceive(rid: String) {
        runOnMainThread {
            Log.d(TAG, "transmitReceiveRegistrationId： $registrationId")
            registrationId = rid
            checkAndTryCleanRidCache()
        }
    }

    internal fun onJPushMessageOperatedResult(
        jPushMessage: JPushMessage,
        type: JPushMessageOperateType
    ) {
        runOnMainThread {
            val sequence = jPushMessage.sequence
            val callback = callbacks[sequence]?.second
            if (callback == null) {
                Log.i(TAG, "callback already removed")
                return@runOnMainThread
            }
            if (jPushMessage.errorCode == 0) { // success
                callback.success(mapOf(Pair("tags", jPushMessage.obtainOperatedProperty(type))))
            } else {
                callback.error(jPushMessage.errorCode.toString(), "", "")
            }
            callbacks.remove(sequence)
        }
    }

    internal fun onNotificationSettingsCheck(isOn: Boolean) {
        runOnMainThread {
            for (jPushPlugin in jPushPlugins) {
                jPushPlugin.onNotificationSettingsCheck(mapOf(Pair("isEnabled", isOn)))
            }
        }
    }

    internal fun checkAndTryCleanCache() {
        runOnMainThread {
            checkAndTryCleanRidCache()
            checkAndTryCleanOpenNotificationCache()
        }
    }

    private fun checkAndTryCleanRidCache() {
        runOnMainThread {
            if (registrationId?.isNotEmpty() == true && obtainRidCache.size > 0) {
                for (ridResult in obtainRidCache) {
                    ridResult.second.success(registrationId)
                }
                obtainRidCache.clear()
            }
        }
    }

    private fun checkAndTryCleanOpenNotificationCache() {
        runOnMainThread {
            if (isSetUpDone && openNotificationCache.size > 0 && jPushPlugins.size > 0) {
                for (notificationMap in openNotificationCache) {
                    for (jPushPlugin in jPushPlugins) {
                        jPushPlugin.onNotificationOpen(notificationMap)
                    }
                }
                openNotificationCache.clear()
            }
        }
    }
}