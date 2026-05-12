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
import cn.jpush.android.api.NotificationCustomButton;
import cn.jpush.android.api.NotificationMessage;
import cn.jpush.android.api.VoipDataMessage;
import cn.jpush.android.local.JPushConstants;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class JPushHelper {
    private static String TAG = "| JPUSH | Flutter | Android | ";
//    private List<Map<String, Object>> openNotificationCache = new ArrayList<>();
//    private List<Map<String, Object>> openMessageCache = new ArrayList<>();
    private List<CachedMessage> calBackMessageCache = new ArrayList<>();
    private boolean dartIsReady = false;
    private boolean jpushDidinit = false;
    private Handler mHandler;

    private List<Result> getRidCache = new ArrayList<>();
    private MethodChannel channel;
    private String currentBindingId; // 记录当前使用的bindingId
    private Map<Integer, Result> callbackMap = new HashMap<>();
    private WeakReference<Context> mContext;
    private Result getPushStatusResult; // 保存 getPushStatus 的 Result

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
    
    public String getCurrentBindingId() {
        return currentBindingId;
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

    public void setGetPushStatusResult(Result result) {
        this.getPushStatusResult = result;
    }

    public Result getGetPushStatusResult() {
        return getPushStatusResult;
    }

    public void clearGetPushStatusResult() {
        this.getPushStatusResult = null;
    }


    public Handler getHandler() {
        if (mHandler == null) {
            mHandler = new Handler(Looper.getMainLooper());
        }
        return mHandler;
    }


    public void setMethodChannel(MethodChannel channel, String bindingId) {
        this.channel = channel;
        this.currentBindingId = bindingId;
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

        JPushHelper.getInstance().getHandler().post(new Runnable() {
            @Override
            public void run() {
                Log.d(TAG, "dispatchNotification");
                invokeMethod(null,null);
            }
        });

//        if (channel == null) {
//            Log.d(TAG, "the channel is null");
//            return;
//        }
//        List<Object> tempList = new ArrayList<Object>();
//        if (dartIsReady) {
//            // try to shedule notifcation cache
//            List<Map<String, Object>> openNotificationCacheList = openNotificationCache;
//            for (Map<String, Object> notification : openNotificationCacheList) {
//                channel.invokeMethod("onOpenNotification", notification);
//                tempList.add(notification);
//            }
//            openNotificationCacheList.removeAll(tempList);
//            tempList.clear();
//
//            List<Map<String, Object>> openMessageCacheList = openMessageCache;
//            for (Map<String, Object> msg : openMessageCacheList) {
//                channel.invokeMethod("onReceiveMessage", msg);
//                tempList.add(msg);
//            }
//            openMessageCacheList.removeAll(tempList);
//            tempList.clear();
//        }
    }

    public void dispatchRid(String rid) {
        if (rid == null || rid.isEmpty()) {
            if (mContext == null || mContext.get() == null) {
                return;
            }
         rid = JPushInterface.getRegistrationID(mContext.get());
        }
        
        List<Object> tempList = new ArrayList<Object>();
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

    public void transmitVoipMessage(VoipDataMessage voipDataMessage) {
        Log.d(TAG, "transmitVoipMessage " + "voipDataMessage=" + voipDataMessage);
        Map<String, Object> msg = new HashMap<>();
        msg.put("messageId", voipDataMessage.getMessageId());
        msg.put("extraData", voipDataMessage.getExtraData());
        msg.put("platform", (int) voipDataMessage.getPlatform());
        invokeMethod("onVoipMessage", msg);
    }

    public void transmitMessageReceive(CustomMessage customMessage) {
        Log.d(TAG, "transmitMessageReceive " + "customMessage=" + customMessage);
        Map<String, Object> msg = new HashMap<>();
        msg.put("message", customMessage.message);
        msg.put("alert", customMessage.title);
        msg.put("extras", getExtras(customMessage));
//        openMessageCache.add(msg);
//        Log.d(TAG, "transmitMessageReceive msg=" + msg);
//        if (channel == null) {
//            Log.d(TAG, "the instance is null");
//            return;
//        }
//        Log.d(TAG, "instance.dartIsReady =" + dartIsReady);
//        if (dartIsReady) {
            invokeMethod("onReceiveMessage", msg);
//            openMessageCache.remove(msg);
//        }
    }

    private void openApp() {
        Context context = mContext.get();
        if (context == null) {
            return;
        }
        Intent launch = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
        if (launch != null) {
            launch.addCategory(Intent.CATEGORY_LAUNCHER);
            launch.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
            context.startActivity(launch);
        }
    }

    public void transmitNotificationOpen(NotificationMessage notificationMessage) {
        Log.d(TAG, "transmitNotificationOpen notificationMessage=" + notificationMessage);
        Map<String, Object> notification = new HashMap<>();
        notification.put("title", notificationMessage.notificationTitle);
        notification.put("alert", notificationMessage.notificationContent);
        notification.put("extras", getExtras(notificationMessage));
//        openNotificationCache.add(notification);
        if (1 == notificationMessage.notificationType) {
            openApp();
        }
//        Log.d(TAG, "transmitNotificationOpen notification=" + notification);
//
//        if (channel == null) {
//            Log.d(TAG, "the channel is null");
//            return;
//        }
//        Log.d(TAG, "instance.dartIsReady =" + dartIsReady);
//        if (dartIsReady) {
            invokeMethod("onOpenNotification", notification);
//            openNotificationCache.remove(notification);
//        }
    }

    public void transmitNotificationReceive(NotificationMessage notificationMessage) {
        Log.d(TAG, "transmitNotificationReceive notificationMessage=" + notificationMessage);
//        Log.d(TAG, "transmitNotificationReceive " + "title=" + title + "alert=" + alert + "extras=" + extras);
//        if (channel == null) {
//            Log.d(TAG, "the channel is null");
//            return;
//        }
        Map<String, Object> notification = new HashMap<>();
        notification.put("title", notificationMessage.notificationTitle);
        notification.put("alert", notificationMessage.notificationContent);
        notification.put("extras", getExtras(notificationMessage));
        Log.d(TAG, "transmitNotificationReceive notification=" + notification);
        invokeMethod("onReceiveNotification", notification);
    }

    public void onCommandResult(CmdMessage cmdMessage) {
        Log.d(TAG, "[onCommandResult] message:" + cmdMessage);
        
        // 处理 getPushStatus 的回调 (cmd == 2003)
        if (cmdMessage != null && cmdMessage.cmd == 2003) {
            Result result = getGetPushStatusResult();
            if (result != null) {
                // 统一返回格式，与 iOS 保持一致
                // errorCode: 0 表示未停止，1 表示已停止，其他表示错误
                int code = 0;
                boolean isStopped = false;
                
                if (cmdMessage.errorCode == 0) {
                    // 未停止
                    code = 0;
                    isStopped = false;
                } else if (cmdMessage.errorCode == 1) {
                    // 已停止
                    code = 0;
                    isStopped = true;
                } else {
                    // 其他错误
                    code = cmdMessage.errorCode;
                    isStopped = false;
                }
                
                Map<String, Object> resultMap = new HashMap<>();
                resultMap.put("code", code);
                resultMap.put("isStopped", isStopped);
                
                getHandler().post(new Runnable() {
                    @Override
                    public void run() {
                        result.success(resultMap);
                        clearGetPushStatusResult();
                    }
                });
                return;
            }
        }
        
//        if (channel == null) {
//            Log.d(TAG, "the channel is null");
//            return;
//        }
        Map<String, Object> notification = new HashMap<>();
        notification.put("cmd", cmdMessage.cmd);
        notification.put("errorCode", cmdMessage.errorCode);
        notification.put("msg", cmdMessage.msg);
        notification.put("extras", bundleToMap(cmdMessage.extra));
        invokeMethod("onCommandResult", notification);
    }

    public void onNotifyMessageUnShow(NotificationMessage notificationMessage) {
        Log.d(TAG, "[onNotifyMessageUnShow] message:" + notificationMessage);
//        if (channel == null) {
//            Log.d(TAG, "the channel is null");
//            return;
//        }
        Map<String, Object> notification = new HashMap<>();
        notification.put("title", notificationMessage.notificationTitle);
        notification.put("alert", notificationMessage.notificationContent);
        notification.put("extras", getExtras(notificationMessage));
        invokeMethod("onNotifyMessageUnShow", notification);
    }

    public void onConnected(boolean isConnected) {
        Log.d(TAG, "[onConnected] :" + isConnected);
//        if (channel == null) {
//            Log.d(TAG, "the channel is null");
//            return;
//        }
        Map<String, Object> results = new HashMap<>();
        results.put("result", isConnected);
        invokeMethod("onConnected", results);
    }

    public void onInAppMessageShow(NotificationMessage notificationMessage) {
        Log.d(TAG, "[onInAppMessageShow] :" + notificationMessage);
//        if (channel == null) {
//            Log.d(TAG, "the channel is null");
//            return;
//        }
        Map<String, Object> notification = new HashMap<>();
        notification.put("title", notificationMessage.inAppMsgTitle);
        notification.put("alert", notificationMessage.inAppMsgContentBody);
        notification.put("messageId", notificationMessage.msgId);
        notification.put("inAppShowTarget", notificationMessage.inAppShowTarget);
        notification.put("inAppClickAction", notificationMessage.inAppClickAction);
        notification.put("inAppExtras", stringToMap(notificationMessage.inAppExtras));
        invokeMethod("onInAppMessageShow", notification);
    }

    public void onInAppMessageClick(NotificationMessage notificationMessage) {
        Log.d(TAG, "[onInAppMessageClick] :" + notificationMessage);
//        if (channel == null) {
//            Log.d(TAG, "the channel is null");
//            return;
//        }
        Map<String, Object> notification = new HashMap<>();
        notification.put("title", notificationMessage.inAppMsgTitle);
        notification.put("alert", notificationMessage.inAppMsgContentBody);
        notification.put("messageId", notificationMessage.msgId);
        notification.put("inAppShowTarget", notificationMessage.inAppShowTarget);
        notification.put("inAppClickAction", notificationMessage.inAppClickAction);
        notification.put("inAppExtras", stringToMap(notificationMessage.inAppExtras));
        invokeMethod("onInAppMessageClick", notification);
    }

    public void onNotifyButtonClick(NotificationCustomButton notificationCustomButton) {
        Log.d(TAG, "[onNotifyButtonClick] :" + notificationCustomButton);
        Map<String, Object> notification = new HashMap<>();
        notification.put("msgId", notificationCustomButton.a);
        notification.put("platform", notificationCustomButton.b);
        notification.put("name", notificationCustomButton.c);
        notification.put("actionType", notificationCustomButton.d);
        notification.put("action", notificationCustomButton.e);
        notification.put("data", notificationCustomButton.f);
        invokeMethod("onNotifyButtonClick", notification);
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

    public static Map<String, Object> bundleToMap(Bundle bundle) {
        Map<String, Object> map = new HashMap<>();
        if (bundle != null) {
            for (String key : bundle.keySet()) {
                if ("intent_component".equals(key) || "intent_action".equals(key)|| "intent_flags".equals(key)) {
                    continue;
                }
                try {
                    Object value = bundle.get(key);
                    if (value instanceof Integer
                            || value instanceof Long
                            || value instanceof Boolean
                            || value instanceof String) {
                        map.put(key, value);
                    } else {
                        map.put(key, String.valueOf(value));
                    }
                } catch (Throwable throwable) {
                }
            }
        }
        return map;
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
                try {
                    String key = keys.next();
                    Object value = object.get(key);
                    if (value instanceof Integer
                            || value instanceof Long
                            || value instanceof Boolean
                            || value instanceof String) {
                        useExtra.put(key, value);
                    } else {
                        useExtra.put(key, String.valueOf(value));
                    }
                } catch (Throwable throwable) {

                }
            }
        } catch (Throwable throwable) {
        }
        return useExtra;
    }


    public void transmitReceiveRegistrationId(String rId) {
        Log.d(TAG, "transmitReceiveRegistrationId： " + rId);
        jpushDidinit = true;
        dispatchNotification();
        dispatchRid(rId);
    }

    // 主线程再返回数据
    public void runMainThread(final Map<String, Object> map, final Result result, final String method) {
        Log.d(TAG, "runMainThread:" + "map = " + map + ",method =" + method);
        getHandler().post(new Runnable() {
            @Override
            public void run() {
                if (result == null && method != null) {
                    if (null != channel) {
                        invokeMethod(method, map);
                    } else {
                        Log.d(TAG, "channel is null do nothing");
                    }
                } else {
                    result.success(map);
                }
            }
        });
    }

    /**
     * 通用方法调用Flutter端
     *
     * @param method 方法名
     * @param msg    参数
     */
    private void invokeMethod(String method, Map<String, Object> msg) {
        if (!dartIsReady) {
            Log.d(TAG, "dartIsReady false: " + method);
            if (method != null) {
                calBackMessageCache.add(new CachedMessage(method, msg));
            } else {
                Log.d(TAG, "skip cache because method is null");
            }
            return;
        } else if (channel == null) {
            Log.d(TAG, "channel is null, cannot invoke " + method);
            if (method != null) {
                calBackMessageCache.add(new CachedMessage(method, msg));
            } else {
                Log.d(TAG, "skip cache because method is null");
            }
            return;
        }

        // 先回放缓存（跳过method为null的脏数据）
        if (!calBackMessageCache.isEmpty()) {
            for (CachedMessage c : calBackMessageCache) {
                if (c.getMethod() == null) {
                    Log.w(TAG, "skip invoking cached message because method is null, data=" + c.getData());
                    continue;
                }
                Log.d(TAG, "method:" + c.getMethod() + ",data:" + c.getData());
                channel.invokeMethod(c.getMethod(), c.getData());
            }
            calBackMessageCache.clear();
        }

        // 当前调用：若method为null直接返回
        if (method == null) {
            Log.d(TAG, "skip current invoke because method is null");
            return;
        }
        Log.d(TAG, "method:" + method + ",msg:" + msg);
        channel.invokeMethod(method, msg);
    }

    /**
     * 缓存消息的数据结构
     */
    private static class CachedMessage {
        private final String method;
        private final Map<String, Object> data;

        public CachedMessage(String method, Map<String, Object> data) {
            this.method = method;
            this.data = data;
        }

        public String getMethod() {
            return method;
        }

        public Map<String, Object> getData() {
            return data;
        }
    }
}
