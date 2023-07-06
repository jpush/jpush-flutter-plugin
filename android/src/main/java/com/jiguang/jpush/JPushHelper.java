package com.jiguang.jpush;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import cn.jpush.android.api.JPushInterface;
import cn.jpush.android.api.NotificationMessage;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class JPushHelper {
    private static String TAG = "| JPUSH | Flutter | Android | ";
    private List<Map<String, Object>> openNotificationCache = new ArrayList<>();

    private boolean dartIsReady = false;
    private boolean jpushDidinit = false;

    private List<Result> getRidCache = new ArrayList<>();
    private Context context;
    private MethodChannel channel;
    private Map<Integer, Result> callbackMap = new HashMap<>();
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
    public Result getCallback(int sequence){
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


    public void setMethodChannel(MethodChannel channel) {
        this.channel = channel;
    }

    public void setContext(Context context) {
        this.context = context;
    }

    public void setDartIsReady(boolean isReady) {
        dartIsReady = isReady;
    }

    public void setJpushDidinit(boolean jpushDidinit) {
        this.jpushDidinit = jpushDidinit;
    }

    public void dispatchNotification() {
        if (channel==null) {
            Log.d("JPushPlugin", "the channel is null");
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
        List<Object> tempList = new ArrayList<Object>();
        String rid = JPushInterface.getRegistrationID(context);
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


    public void transmitMessageReceive(String message,String title, Map<String, Object> extras) {
        Log.d(TAG, "transmitMessageReceive " + "message=" + message + "extras=" + extras);

        if (channel==null) {
            Log.d("JPushPlugin", "the instance is null");
            return;
        }
        Map<String, Object> msg = new HashMap<>();
        msg.put("message", message);
        msg.put("alert", title);
        msg.put("extras", extras);

        channel.invokeMethod("onReceiveMessage", msg);
    }

    public void transmitNotificationOpen(String title, String alert, Map<String, Object> extras) {
        Log.d(TAG, "transmitNotificationOpen " + "title=" + title + "alert=" + alert + "extras=" + extras);

        Map<String, Object> notification = new HashMap<>();
        notification.put("title", title);
        notification.put("alert", alert);
        notification.put("extras", extras);
        openNotificationCache.add(notification);

        if (channel==null) {
            Log.d("JPushPlugin", "the channel is null");
            return;
        }
        Log.d("JPushPlugin", "instance.dartIsReady ="+dartIsReady);
        if (dartIsReady) {
            channel.invokeMethod("onOpenNotification", notification);
            openNotificationCache.remove(notification);
        }
    }

    public  void onNotifyMessageUnShow( NotificationMessage notificationMessage) {
        Log.e(TAG,"[onNotifyMessageUnShow] message:"+notificationMessage);
        if (channel==null) {
            Log.d("JPushPlugin", "the channel is null");
            return;
        }
        Map<String, Object> notification= new HashMap<>();
        notification.put("title", notificationMessage.notificationTitle);
        notification.put("alert", notificationMessage.notificationContent);
        notification.put("extras", getExtras(notificationMessage));
        channel.invokeMethod("onNotifyMessageUnShow", notification);
    }
    public  void onConnected( boolean isConnected) {
        Log.e(TAG,"[onConnected] :"+isConnected);
        if (channel==null) {
            Log.d("JPushPlugin", "the channel is null");
            return;
        }
        Map<String, Object> results= new HashMap<>();
        results.put("result", isConnected);
       channel.invokeMethod("onConnected", results);
    }
    public  void onInAppMessageShow( NotificationMessage notificationMessage) {
        Log.e(TAG,"[onInAppMessageShow] :"+notificationMessage);
        if (channel==null) {
            Log.d("JPushPlugin", "the channel is null");
            return;
        }
        Map<String, Object> notification= new HashMap<>();
        notification.put("title", notificationMessage.inAppMsgTitle);
        notification.put("alert", notificationMessage.inAppMsgContentBody);
        notification.put("messageId", notificationMessage.msgId);
        notification.put("inAppShowTarget",  notificationMessage.inAppExtras);
        notification.put("inAppClickAction",  notificationMessage.inAppClickAction);
        notification.put("inAppExtras", notificationMessage.inAppExtras);
        channel.invokeMethod("onInAppMessageShow", notification);
    }
    public  void onInAppMessageClick( NotificationMessage notificationMessage) {
        Log.e(TAG,"[onInAppMessageClick] :"+notificationMessage);
        if (channel==null) {
            Log.d("JPushPlugin", "the channel is null");
            return;
        }
        Map<String, Object> notification= new HashMap<>();
        notification.put("title", notificationMessage.inAppMsgTitle);
        notification.put("alert", notificationMessage.inAppMsgContentBody);
        notification.put("messageId", notificationMessage.msgId);
        notification.put("inAppShowTarget",  notificationMessage.inAppExtras);
        notification.put("inAppClickAction",  notificationMessage.inAppClickAction);
        notification.put("inAppExtras", notificationMessage.inAppExtras);
        channel.invokeMethod("onInAppMessageClick", notification);
    }


    private  Map<String,Object> getExtras(NotificationMessage notificationMessage){
        Map<String, Object> extras= new HashMap<>();
        try {
            extras.put(JPushInterface.EXTRA_MSG_ID, notificationMessage.msgId);
            extras.put(JPushInterface.EXTRA_NOTIFICATION_ID, notificationMessage.notificationId);
            extras.put(JPushInterface.EXTRA_ALERT_TYPE, notificationMessage.notificationAlertType + "");
            if (!TextUtils.isEmpty(notificationMessage.notificationExtras)) {
                extras.put(JPushInterface.EXTRA_EXTRA, notificationMessage.notificationExtras);
            }
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
        }catch (Throwable e){
            Log.e(TAG,"[onNotifyMessageUnShow] e:"+e.getMessage());
        }
        return extras;
    }
    public void transmitNotificationReceive(String title, String alert, Map<String, Object> extras) {
        Log.d(TAG, "transmitNotificationReceive " + "title=" + title + "alert=" + alert + "extras=" + extras);
        if (channel==null) {
            Log.d("JPushPlugin", "the channel is null");
            return;
        }
        Map<String, Object> notification = new HashMap<>();
        notification.put("title", title);
        notification.put("alert", alert);
        notification.put("extras", extras);
        channel.invokeMethod("onReceiveNotification", notification);
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
        android.os.Handler handler = new Handler(Looper.getMainLooper());
        handler.post(new Runnable() {
            @Override
            public void run() {
                if (result == null && method != null) {
                    if( null != channel){
                        channel.invokeMethod(method,map);
                    }else {
                        Log.d(TAG,"channel is null do nothing");
                    }
                } else {
                    result.success(map);
                }
            }
        });
    }
}
