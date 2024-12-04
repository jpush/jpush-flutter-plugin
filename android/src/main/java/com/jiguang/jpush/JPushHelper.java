package com.jiguang.jpush;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import org.json.JSONObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import cn.jpush.android.api.CmdMessage;
import cn.jpush.android.api.CustomMessage;
import cn.jpush.android.api.JPushInterface;
import cn.jpush.android.api.NotificationMessage;
import cn.jpush.android.local.JPushConstants;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class JPushHelper {
    private static String TAG = "| JPUSH | Flutter | Android | ";
    private List<Map<String, Object>> openNotificationCache = new ArrayList<>();

    private boolean dartIsReady = false;
    private boolean jpushDidinit = false;
    private Handler mHandler;

    private List<Result> getRidCache = new ArrayList<>();
    private MethodChannel channel;
    private Map<Integer, Result> callbackMap = new HashMap<>();
    private WeakReference<Context> mContext;

    private JPushHelper() {
    }

    private static final class SingleHolder {
        private static final JPushHelper single = new JPushHelper();
    }

    public static JPushHelper getInstance() {
        return SingleHolder.single;
    }


    public MethodChannel getChannel() {
        return channel;
    }

    public Result getCallback(int sequence) {
        return callbackMap.get(sequence);
    }

    public void addCallback(int sequence, Result result) {
        callbackMap.put(sequence, result);
    }

    public void removeCallback(int sequence) {
        callbackMap.remove(sequence);
    }

    public void addRid(Result result) {
        getRidCache.add(result);
    }


    public Handler getHandler() {
        if (mHandler == null) {
            mHandler = new Handler(Looper.getMainLooper());
        }
        return mHandler;
    }

    public void setMethodChannel(MethodChannel channel) {
        this.channel = channel;
    }

    public void setContext(Context context) {
        if (mContext != null) {
            mContext.clear();
            mContext = null;
        }
        mContext = new WeakReference<>(context.getApplicationContext());
        mHandler = new Handler(Looper.getMainLooper());
    }

    public void setDartIsReady(boolean isReady) {
        dartIsReady = isReady;
    }

    public void setJpushDidinit(boolean jpushDidinit) {
        this.jpushDidinit = jpushDidinit;
    }

    public void dispatchNotification() {
        if (channel == null) {
            Log.d(TAG, "the channel is null");
            return;
        }
        List<Object> tempList = new ArrayList<Object>();
        if (dartIsReady) {
            // try to shedule notifcation cache
            List<Map<String, Object>> openNotificationCacheList = openNotificationCache;
            for (Map<String, Object> notification : openNotificationCacheList) {
                channel.invokeMethod("onOpenNotification", notification);
                tempList.add(notification);
            }
            openNotificationCacheList.removeAll(tempList);
            tempList.clear();
        }
    }

    public void dispatchRid() {
        if (mContext == null || mContext.get() == null) {
            return;
        }
        List<Object> tempList = new ArrayList<Object>();
        String rid = JPushInterface.getRegistrationID(mContext.get());
        boolean ridAvailable = rid != null && !rid.isEmpty();
        if (ridAvailable && dartIsReady) {
            // try to schedule get rid cache
            tempList.clear();
            List<Result> resultList = getRidCache;
            for (Result res : resultList) {
                Log.d(TAG, "scheduleCache rid = " + rid);
                res.success(rid);
                tempList.add(res);
            }
            resultList.removeAll(tempList);
            tempList.clear();
        }
    }


    public void transmitMessageReceive(CustomMessage customMessage) {
        Log.d(TAG, "transmitMessageReceive " + "customMessage=" + customMessage);

        if (channel == null) {
            Log.d(TAG, "the instance is null");
            return;
        }
        Map<String, Object> msg = new HashMap<>();
        msg.put("message", customMessage.message);
        msg.put("alert", customMessage.title);
        msg.put("extras", getExtras(customMessage));
        Log.d(TAG, "transmitMessageReceive msg=" + msg);
        channel.invokeMethod("onReceiveMessage", msg);
    }

    public void transmitNotificationOpen(NotificationMessage notificationMessage) {
        Log.d(TAG, "transmitNotificationOpen notificationMessage=" + notificationMessage);
        Map<String, Object> notification = new HashMap<>();
        notification.put("title", notificationMessage.notificationTitle);
        notification.put("alert", notificationMessage.notificationContent);
        notification.put("extras", getExtras(notificationMessage));
        openNotificationCache.add(notification);
        Log.d(TAG, "transmitNotificationOpen notification=" + notification);
        if (channel == null) {
            Log.d(TAG, "the channel is null");
            return;
        }
        Log.d(TAG, "instance.dartIsReady =" + dartIsReady);
        if (dartIsReady) {
            channel.invokeMethod("onOpenNotification", notification);
            openNotificationCache.remove(notification);
        }
    }

    public void transmitNotificationReceive(NotificationMessage notificationMessage) {
        Log.d(TAG, "transmitNotificationReceive notificationMessage=" + notificationMessage);
//        Log.d(TAG, "transmitNotificationReceive " + "title=" + title + "alert=" + alert + "extras=" + extras);
        if (channel == null) {
            Log.d(TAG, "the channel is null");
            return;
        }
        Map<String, Object> notification = new HashMap<>();
        notification.put("title", notificationMessage.notificationTitle);
        notification.put("alert", notificationMessage.notificationContent);
        notification.put("extras", getExtras(notificationMessage));
        Log.d(TAG, "transmitNotificationReceive notification=" + notification);
        channel.invokeMethod("onReceiveNotification", notification);
    }

    public void onCommandResult(CmdMessage cmdMessage) {
        Log.e(TAG, "[onCommandResult] message:" + cmdMessage);
        if (channel == null) {
            Log.d(TAG, "the channel is null");
            return;
        }
        Map<String, Object> notification = new HashMap<>();
        notification.put("cmd", cmdMessage.cmd);
        notification.put("errorCode", cmdMessage.errorCode);
        notification.put("msg", cmdMessage.msg);
//        notification.put("extras", getExtras(cmdMessage));
        channel.invokeMethod("onCommandResult", notification);
    }

    public void onNotifyMessageUnShow(NotificationMessage notificationMessage) {
        Log.e(TAG, "[onNotifyMessageUnShow] message:" + notificationMessage);
        if (channel == null) {
            Log.d(TAG, "the channel is null");
            return;
        }
        Map<String, Object> notification = new HashMap<>();
        notification.put("title", notificationMessage.notificationTitle);
        notification.put("alert", notificationMessage.notificationContent);
        notification.put("extras", getExtras(notificationMessage));
        channel.invokeMethod("onNotifyMessageUnShow", notification);
    }

    public void onConnected(boolean isConnected) {
        Log.e(TAG, "[onConnected] :" + isConnected);
        if (channel == null) {
            Log.d(TAG, "the channel is null");
            return;
        }
        Map<String, Object> results = new HashMap<>();
        results.put("result", isConnected);
        channel.invokeMethod("onConnected", results);
    }

    public void onInAppMessageShow(NotificationMessage notificationMessage) {
        Log.e(TAG, "[onInAppMessageShow] :" + notificationMessage);
        if (channel == null) {
            Log.d(TAG, "the channel is null");
            return;
        }
        Map<String, Object> notification = new HashMap<>();
        notification.put("title", notificationMessage.inAppMsgTitle);
        notification.put("alert", notificationMessage.inAppMsgContentBody);
        notification.put("messageId", notificationMessage.msgId);
        notification.put("inAppShowTarget", notificationMessage.inAppShowTarget);
        notification.put("inAppClickAction", notificationMessage.inAppClickAction);
        notification.put("inAppExtras", stringToMap(notificationMessage.inAppExtras));
        channel.invokeMethod("onInAppMessageShow", notification);
    }

    public void onInAppMessageClick(NotificationMessage notificationMessage) {
        Log.e(TAG, "[onInAppMessageClick] :" + notificationMessage);
        if (channel == null) {
            Log.d(TAG, "the channel is null");
            return;
        }
        Map<String, Object> notification = new HashMap<>();
        notification.put("title", notificationMessage.inAppMsgTitle);
        notification.put("alert", notificationMessage.inAppMsgContentBody);
        notification.put("messageId", notificationMessage.msgId);
        notification.put("inAppShowTarget", notificationMessage.inAppShowTarget);
        notification.put("inAppClickAction", notificationMessage.inAppClickAction);
        notification.put("inAppExtras", stringToMap(notificationMessage.inAppExtras));
        channel.invokeMethod("onInAppMessageClick", notification);
    }

    private Map<String, Object> getExtras(CustomMessage customMessage) {
        Map<String, Object> extra = new HashMap<>();
        extra.put(JPushInterface.EXTRA_EXTRA, stringToMap(customMessage.extra));
        extra.put(JPushInterface.EXTRA_MSG_ID, customMessage.messageId);
        extra.put(JPushInterface.EXTRA_CONTENT_TYPE, customMessage.contentType);
        if (JPushConstants.SDK_VERSION_CODE >= 387) {
            extra.put(JPushInterface.EXTRA_TYPE_PLATFORM, customMessage.platform);
        }
        return extra;
    }

    private Map<String, Object> getExtras(NotificationMessage notificationMessage) {
        Map<String, Object> extras = new HashMap<>();
        try {
            extras.put(JPushInterface.EXTRA_MSG_ID, notificationMessage.msgId);
            extras.put(JPushInterface.EXTRA_NOTIFICATION_ID, notificationMessage.notificationId);
            extras.put(JPushInterface.EXTRA_ALERT_TYPE, notificationMessage.notificationAlertType + "");
            extras.put(JPushInterface.EXTRA_EXTRA, stringToMap(notificationMessage.notificationExtras));
            if (notificationMessage.notificationStyle == 1 && !TextUtils.isEmpty(notificationMessage.notificationBigText)) {
                extras.put(JPushInterface.EXTRA_BIG_TEXT, notificationMessage.notificationBigText);
            } else if (notificationMessage.notificationStyle == 2 && !TextUtils.isEmpty(notificationMessage.notificationInbox)) {
                extras.put(JPushInterface.EXTRA_INBOX, notificationMessage.notificationInbox);
            } else if ((notificationMessage.notificationStyle == 3) && !TextUtils.isEmpty(notificationMessage.notificationBigPicPath)) {
                extras.put(JPushInterface.EXTRA_BIG_PIC_PATH, notificationMessage.notificationBigPicPath);
            }
            if (!(notificationMessage.notificationPriority == 0)) {
                extras.put(JPushInterface.EXTRA_NOTI_PRIORITY, notificationMessage.notificationPriority + "");
            }
            if (!TextUtils.isEmpty(notificationMessage.notificationCategory)) {
                extras.put(JPushInterface.EXTRA_NOTI_CATEGORY, notificationMessage.notificationCategory);
            }
            if (!TextUtils.isEmpty(notificationMessage.notificationSmallIcon)) {
                extras.put(JPushInterface.EXTRA_NOTIFICATION_SMALL_ICON, notificationMessage.notificationSmallIcon);
            }
            if (!TextUtils.isEmpty(notificationMessage.notificationLargeIcon)) {
                extras.put(JPushInterface.EXTRA_NOTIFICATION_LARGET_ICON, notificationMessage.notificationLargeIcon);
            }
        } catch (Throwable e) {
            Log.e(TAG, "[onNotifyMessageUnShow] e:" + e.getMessage());
        }
        return extras;
    }

    public Map<String, Object> stringToMap(String extra) {
        Map<String, Object> useExtra = new HashMap<String, Object>();
        try {
            if (TextUtils.isEmpty(extra)) {
                return useExtra;
            }
            JSONObject object = new JSONObject(extra);
            Iterator<String> keys = object.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                Object value = object.get(key);
                useExtra.put(key, value);
            }
        } catch (Throwable throwable) {
        }
        return useExtra;
    }


    public void transmitReceiveRegistrationId(String rId) {
        Log.d(TAG, "transmitReceiveRegistrationId： " + rId);
        jpushDidinit = true;
        dispatchNotification();
        dispatchRid();
    }

    // 主线程再返回数据
    public void runMainThread(final Map<String, Object> map, final Result result, final String method) {
        Log.d(TAG, "runMainThread:" + "map = " + map + ",method =" + method);
        getHandler().post(new Runnable() {
            @Override
            public void run() {
                if (result == null && method != null) {
                    if (null != channel) {
                        channel.invokeMethod(method, map);
                    } else {
                        Log.d(TAG, "channel is null do nothing");
                    }
                } else {
                    result.success(map);
                }
            }
        });
    }
}
