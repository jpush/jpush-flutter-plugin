package com.jiguang.jpush

import android.content.Context
import android.content.Intent
import android.util.Log
import cn.jpush.android.api.CustomMessage
import cn.jpush.android.api.JPushInterface
import cn.jpush.android.api.JPushMessage
import cn.jpush.android.api.NotificationMessage
import cn.jpush.android.service.JPushMessageReceiver

private const val TAG = "JPushEventReceiver"

fun NotificationMessage.extrasMap(): Map<String, Any> {
    return mapOf(
        Pair(JPushInterface.EXTRA_EXTRA, notificationExtras),
        Pair(JPushInterface.EXTRA_ALERT_TYPE, notificationAlertType),
        Pair(JPushInterface.EXTRA_NOTIFICATION_ID, notificationId),
        Pair(JPushInterface.EXTRA_MSG_ID, msgId),
        Pair(JPushInterface.EXTRA_ALERT, notificationContent),
        Pair(JPushInterface.EXTRA_NOTIFICATION_TITLE, notificationTitle),
        Pair(JPushInterface.EXTRA_NOTI_TYPE, notificationType),
        Pair(JPushInterface.EXTRA_BIG_TEXT, notificationBigText),
        Pair(JPushInterface.EXTRA_INBOX, notificationInbox),
        Pair(JPushInterface.EXTRA_BIG_PIC_PATH, notificationBigPicPath),
        Pair(JPushInterface.EXTRA_NOTI_PRIORITY, notificationPriority),
        Pair(JPushInterface.EXTRA_NOTI_CATEGORY, notificationCategory),
        Pair(JPushInterface.EXTRA_NOTIFICATION_SMALL_ICON, notificationSmallIcon),
        Pair(JPushInterface.EXTRA_NOTIFICATION_LARGET_ICON, notificationLargeIcon),
        Pair(JPushInterface.EXTRA_TYPE_PLATFORM, platform),
    )
}

/**
 * 基于广播接收各种回调，进行数据校验后分派给JPushCallbackDispatcher处理
 */
class JPushEventReceiver : JPushMessageReceiver() {

    override fun onRegister(context: Context?, registrationId: String?) {
        super.onRegister(context, registrationId)
        if (registrationId.isNullOrEmpty()) {
            Log.d(TAG, "onRegister: registrationId null or empty")
        } else {
            JPushCallbackDispatcher.onRegistrationIdReceive(registrationId)
        }
    }

    override fun onMessage(context: Context?, message: CustomMessage?) {
        super.onMessage(context, message)
        val msg = message?.message
        val extra = mapOf(Pair(JPushInterface.EXTRA_EXTRA, message?.extra))
        JPushCallbackDispatcher.onMessageReceive(msg, extra)
    }

    override fun onNotifyMessageArrived(context: Context?, notification: NotificationMessage?) {
        super.onNotifyMessageArrived(context, notification)
        val title = notification?.notificationTitle
        val alert = notification?.notificationContent
        JPushCallbackDispatcher.onNotificationReceive(title, alert, notification?.extrasMap())
    }

    override fun onNotifyMessageOpened(context: Context?, notification: NotificationMessage?) {
        super.onNotifyMessageOpened(context, notification)
        val title = notification?.notificationTitle
        val alert = notification?.notificationContent
        JPushCallbackDispatcher.onNotificationOpen(title, alert, notification?.extrasMap())
        val launch = context?.packageManager?.getLaunchIntentForPackage(context.packageName)
        if (launch != null) {
            launch.addCategory(Intent.CATEGORY_LAUNCHER)
            launch.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            context.startActivity(launch)
        }
    }

    override fun onTagOperatorResult(context: Context?, jPushMessage: JPushMessage?) {
        super.onTagOperatorResult(context, jPushMessage)
        Log.d(TAG, "onTagOperatorResult: ${jPushMessage?.tags}")
        jPushMessage?.let {
            JPushCallbackDispatcher.onJPushMessageOperatedResult(
                jPushMessage,
                JPushMessageOperateType.TAG,
            )
        }
    }

    override fun onCheckTagOperatorResult(context: Context?, jPushMessage: JPushMessage?) {
        super.onCheckTagOperatorResult(context, jPushMessage)
        Log.d(TAG, "onCheckTagOperatorResult: ${jPushMessage?.tags}")
        jPushMessage?.let {
            JPushCallbackDispatcher.onJPushMessageOperatedResult(
                jPushMessage,
                JPushMessageOperateType.TAG,
            )
        }
    }

    override fun onAliasOperatorResult(context: Context?, jPushMessage: JPushMessage?) {
        super.onAliasOperatorResult(context, jPushMessage)
        Log.d(TAG, "onAliasOperatorResult: ${jPushMessage?.alias}")
        jPushMessage?.let {
            JPushCallbackDispatcher.onJPushMessageOperatedResult(
                jPushMessage,
                JPushMessageOperateType.ALIAS,
            )
        }
    }

    override fun onNotificationSettingsCheck(context: Context?, isOn: Boolean, source: Int) {
        super.onNotificationSettingsCheck(context, isOn, source)
        Log.d(TAG, "onNotificationSettingsCheck: isOn = $isOn")
        JPushCallbackDispatcher.onNotificationSettingsCheck(isOn)
    }
}