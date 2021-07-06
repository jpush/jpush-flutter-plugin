package com.jiguang.jpush;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import cn.jiguang.api.JCoreInterface;
import cn.jpush.android.api.JPushInterface;
import cn.jpush.android.data.JPushLocalNotification;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * JPushPlugin
 */
public class JPushPlugin implements FlutterPlugin, MethodCallHandler {


    private static String TAG = "| JPUSH | Flutter | Android | ";

    public static JPushPlugin instance;

    static List<Map<String, Object>> openNotificationCache = new ArrayList<>();

    private boolean dartIsReady = false;
    private boolean jpushDidinit = false;

    private List<Result> getRidCache;

    private Context context;
    private MethodChannel channel;
    public Map<Integer, Result> callbackMap;
    private int sequence;

    public JPushPlugin() {
        this.callbackMap = new HashMap<>();
        this.sequence = 0;
        this.getRidCache = new ArrayList<>();
        instance = this;
    }


    @Override
    public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "jpush");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }


    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        instance.dartIsReady = false;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        Log.i(TAG, call.method);
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("setup")) {
            setup(call, result);
        } else if (call.method.equals("setTags")) {
            setTags(call, result);
        } else if (call.method.equals("cleanTags")) {
            cleanTags(call, result);
        } else if (call.method.equals("addTags")) {
            addTags(call, result);
        } else if (call.method.equals("deleteTags")) {
            deleteTags(call, result);
        } else if (call.method.equals("getAllTags")) {
            getAllTags(call, result);
        } else if (call.method.equals("setAlias")) {
            setAlias(call, result);
        } else if (call.method.equals("deleteAlias")) {
            deleteAlias(call, result);
            ;
        } else if (call.method.equals("stopPush")) {
            stopPush(call, result);
        } else if (call.method.equals("resumePush")) {
            resumePush(call, result);
        } else if (call.method.equals("clearAllNotifications")) {
            clearAllNotifications(call, result);
        } else if (call.method.equals("clearNotification")) {
            clearNotification(call, result);
        } else if (call.method.equals("getLaunchAppNotification")) {
            getLaunchAppNotification(call, result);
        } else if (call.method.equals("getRegistrationID")) {
            getRegistrationID(call, result);
        } else if (call.method.equals("sendLocalNotification")) {
            sendLocalNotification(call, result);
        } else if (call.method.equals("setBadge")) {
            setBadge(call, result);
        } else if (call.method.equals("isNotificationEnabled")) {
            isNotificationEnabled(call, result);
        } else if (call.method.equals("openSettingsForNotification")) {
            openSettingsForNotification(call, result);
        } else if (call.method.equals("setWakeEnable")) {
            setWakeEnable(call, result);
        } else {
            result.notImplemented();
        }
    }

    private void setWakeEnable(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        if (map == null) {
            return;
        }
        Boolean enable = (Boolean) map.get("enable");
        if (enable == null) {
            enable = false;
        }
        JCoreInterface.setWakeEnable(context,enable);
    }

    // 主线程再返回数据
    public void runMainThread(final Map<String, Object> map, final Result result, final String method) {
        Log.d(TAG, "runMainThread:" + "map = " + map + ",method =" + method);
        android.os.Handler handler = new Handler(Looper.getMainLooper());
        handler.post(new Runnable() {
            @Override
            public void run() {
                if (result == null && method != null) {
                    channel.invokeMethod(method, map);
                } else {
                    result.success(map);
                }
            }
        });
    }

    public void setup(MethodCall call, Result result) {
        Log.d(TAG, "setup :" + call.arguments);

        HashMap<String, Object> map = call.arguments();
        boolean debug = (boolean) map.get("debug");
        JPushInterface.setDebugMode(debug);

        JPushInterface.init(context);            // 初始化 JPush

        String channel = (String) map.get("channel");
        JPushInterface.setChannel(context, channel);

        JPushPlugin.instance.dartIsReady = true;

        // try to clean getRid cache
        scheduleCache();
    }

    public void scheduleCache() {
        Log.d(TAG, "scheduleCache:");

        List<Object> tempList = new ArrayList<Object>();

        if (dartIsReady) {
            // try to shedule notifcation cache
            List<Map<String, Object>> openNotificationCacheList = JPushPlugin.openNotificationCache;
            for (Map<String, Object> notification : openNotificationCacheList) {
                JPushPlugin.instance.channel.invokeMethod("onOpenNotification", notification);
                tempList.add(notification);
            }
            openNotificationCacheList.removeAll(tempList);
        }

        if (context == null) {
            Log.d(TAG, "scheduleCache，register context is nil.");
            return;
        }

        String rid = JPushInterface.getRegistrationID(context);
        boolean ridAvailable = rid != null && !rid.isEmpty();
        if (ridAvailable && dartIsReady) {
            // try to schedule get rid cache
            tempList.clear();
            List<Result> resultList = JPushPlugin.instance.getRidCache;
            for (Result res : resultList) {
                Log.d(TAG, "scheduleCache rid = " + rid);
                res.success(rid);
                tempList.add(res);
            }
            resultList.removeAll(tempList);
        }
    }

    public void setTags(MethodCall call, Result result) {
        Log.d(TAG, "setTags：");

        List<String> tagList = call.arguments();
        Set<String> tags = new HashSet<>(tagList);
        sequence += 1;
        callbackMap.put(sequence, result);
        JPushInterface.setTags(context, sequence, tags);
    }

    public void cleanTags(MethodCall call, Result result) {
        Log.d(TAG, "cleanTags:");

        sequence += 1;
        callbackMap.put(sequence, result);
        JPushInterface.cleanTags(context, sequence);
    }

    public void addTags(MethodCall call, Result result) {
        Log.d(TAG, "addTags: " + call.arguments);

        List<String> tagList = call.arguments();
        Set<String> tags = new HashSet<>(tagList);
        sequence += 1;
        callbackMap.put(sequence, result);
        JPushInterface.addTags(context, sequence, tags);
    }

    public void deleteTags(MethodCall call, Result result) {
        Log.d(TAG, "deleteTags： " + call.arguments);

        List<String> tagList = call.arguments();
        Set<String> tags = new HashSet<>(tagList);
        sequence += 1;
        callbackMap.put(sequence, result);
        JPushInterface.deleteTags(context, sequence, tags);
    }

    public void getAllTags(MethodCall call, Result result) {
        Log.d(TAG, "getAllTags： ");

        sequence += 1;
        callbackMap.put(sequence, result);
        JPushInterface.getAllTags(context, sequence);
    }

    public void setAlias(MethodCall call, Result result) {
        Log.d(TAG, "setAlias: " + call.arguments);

        String alias = call.arguments();
        sequence += 1;
        callbackMap.put(sequence, result);
        JPushInterface.setAlias(context, sequence, alias);
    }

    public void deleteAlias(MethodCall call, Result result) {
        Log.d(TAG, "deleteAlias:");

        String alias = call.arguments();
        sequence += 1;
        callbackMap.put(sequence, result);
        JPushInterface.deleteAlias(context, sequence);
    }

    public void stopPush(MethodCall call, Result result) {
        Log.d(TAG, "stopPush:");

        JPushInterface.stopPush(context);
    }

    public void resumePush(MethodCall call, Result result) {
        Log.d(TAG, "resumePush:");

        JPushInterface.resumePush(context);
    }

    public void clearAllNotifications(MethodCall call, Result result) {
        Log.d(TAG, "clearAllNotifications: ");

        JPushInterface.clearAllNotifications(context);
    }

    public void clearNotification(MethodCall call, Result result) {
        Log.d(TAG, "clearNotification: ");
        Object id = call.arguments;
        if (id != null) {
            JPushInterface.clearNotificationById(context, (int) id);
        }
    }

    public void getLaunchAppNotification(MethodCall call, Result result) {
        Log.d(TAG, "");


    }

    public void getRegistrationID(MethodCall call, Result result) {
        Log.d(TAG, "getRegistrationID: ");

        if (context == null) {
            Log.d(TAG, "register context is nil.");
            return;
        }

        String rid = JPushInterface.getRegistrationID(context);
        if (rid == null || rid.isEmpty()) {
            getRidCache.add(result);
        } else {
            result.success(rid);
        }
    }


    public void sendLocalNotification(MethodCall call, Result result) {
        Log.d(TAG, "sendLocalNotification: " + call.arguments);

        try {
            HashMap<String, Object> map = call.arguments();

            JPushLocalNotification ln = new JPushLocalNotification();
            ln.setBuilderId((Integer) map.get("buildId"));
            ln.setNotificationId((Integer) map.get("id"));
            ln.setTitle((String) map.get("title"));
            ln.setContent((String) map.get("content"));
            HashMap<String, Object> extra = (HashMap<String, Object>) map.get("extra");

            if (extra != null) {
                JSONObject json = new JSONObject(extra);
                ln.setExtras(json.toString());
            }

            long date = (long) map.get("fireTime");
            ln.setBroadcastTime(date);

            JPushInterface.addLocalNotification(context, ln);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void setBadge(MethodCall call, Result result) {
        Log.d(TAG, "setBadge: " + call.arguments);

        HashMap<String, Object> map = call.arguments();
        Object numObject = map.get("badge");
        if (numObject != null) {
            int num = (int) numObject;
            JPushInterface.setBadgeNumber(context, num);
            result.success(true);
        }
    }

    /// 检查当前应用的通知开关是否开启
    private void isNotificationEnabled(MethodCall call, Result result) {
        Log.d(TAG, "isNotificationEnabled: ");
        int isEnabled = JPushInterface.isNotificationEnabled(context);
        //1表示开启，0表示关闭，-1表示检测失败
        HashMap<String, Object> map = new HashMap();
        map.put("isEnabled", isEnabled == 1 ? true : false);

        runMainThread(map, result, null);
    }

    private void openSettingsForNotification(MethodCall call, Result result) {
        Log.d(TAG, "openSettingsForNotification: ");

        JPushInterface.goToAppNotificationSettings(context);

    }

    /**
     * 接收自定义消息,通知,通知点击事件等事件的广播
     * 文档链接:http://docs.jiguang.cn/client/android_api/
     */
    public static class JPushReceiver extends BroadcastReceiver {

        private static final List<String> IGNORED_EXTRAS_KEYS = Arrays.asList("cn.jpush.android.TITLE",
                "cn.jpush.android.MESSAGE", "cn.jpush.android.APPKEY", "cn.jpush.android.NOTIFICATION_CONTENT_TITLE", "key_show_entity", "platform");

        public JPushReceiver() {
        }


        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();

            if (action.equals(JPushInterface.ACTION_REGISTRATION_ID)) {
                String rId = intent.getStringExtra(JPushInterface.EXTRA_REGISTRATION_ID);
                Log.d("JPushPlugin", "on get registration");
                JPushPlugin.transmitReceiveRegistrationId(rId);

            } else if (action.equals(JPushInterface.ACTION_MESSAGE_RECEIVED)) {
                handlingMessageReceive(intent);
            } else if (action.equals(JPushInterface.ACTION_NOTIFICATION_RECEIVED)) {
                handlingNotificationReceive(context, intent);
            } else if (action.equals(JPushInterface.ACTION_NOTIFICATION_OPENED)) {
                handlingNotificationOpen(context, intent);
            }
        }

        private void handlingMessageReceive(Intent intent) {
            Log.d(TAG, "handlingMessageReceive " + intent.getAction());

            String msg = intent.getStringExtra(JPushInterface.EXTRA_MESSAGE);
            Map<String, Object> extras = getNotificationExtras(intent);
            JPushPlugin.transmitMessageReceive(msg, extras);
        }

        private void handlingNotificationOpen(Context context, Intent intent) {
            Log.d(TAG, "handlingNotificationOpen " + intent.getAction());

            String title = intent.getStringExtra(JPushInterface.EXTRA_NOTIFICATION_TITLE);
            String alert = intent.getStringExtra(JPushInterface.EXTRA_ALERT);
            Map<String, Object> extras = getNotificationExtras(intent);
            JPushPlugin.transmitNotificationOpen(title, alert, extras);

            Intent launch = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
            if (launch != null) {
                launch.addCategory(Intent.CATEGORY_LAUNCHER);
                launch.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
                context.startActivity(launch);
            }
        }

        private void handlingNotificationReceive(Context context, Intent intent) {
            Log.d(TAG, "handlingNotificationReceive " + intent.getAction());

            String title = intent.getStringExtra(JPushInterface.EXTRA_NOTIFICATION_TITLE);
            String alert = intent.getStringExtra(JPushInterface.EXTRA_ALERT);
            Map<String, Object> extras = getNotificationExtras(intent);
            JPushPlugin.transmitNotificationReceive(title, alert, extras);
        }

        private Map<String, Object> getNotificationExtras(Intent intent) {
            Log.d(TAG, "");

            Map<String, Object> extrasMap = new HashMap<String, Object>();
            for (String key : intent.getExtras().keySet()) {
                if (!IGNORED_EXTRAS_KEYS.contains(key)) {
                    if (key.equals(JPushInterface.EXTRA_NOTIFICATION_ID)) {
                        extrasMap.put(key, intent.getIntExtra(key, 0));
                    } else {
                        extrasMap.put(key, intent.getStringExtra(key));
                    }
                }
            }
            return extrasMap;
        }
    }


    static void transmitMessageReceive(String message, Map<String, Object> extras) {
        Log.d(TAG, "transmitMessageReceive " + "message=" + message + "extras=" + extras);

        if (instance == null) {
            return;
        }
        Map<String, Object> msg = new HashMap<>();
        msg.put("message", message);
        msg.put("extras", extras);

        JPushPlugin.instance.channel.invokeMethod("onReceiveMessage", msg);
    }

    static void transmitNotificationOpen(String title, String alert, Map<String, Object> extras) {
        Log.d(TAG, "transmitNotificationOpen " + "title=" + title + "alert=" + alert + "extras=" + extras);

        Map<String, Object> notification = new HashMap<>();
        notification.put("title", title);
        notification.put("alert", alert);
        notification.put("extras", extras);
        JPushPlugin.openNotificationCache.add(notification);

        if (instance == null) {
            Log.d("JPushPlugin", "the instance is null");
            return;
        }

        if (instance.dartIsReady) {
            Log.d("JPushPlugin", "instance.dartIsReady is true");
            JPushPlugin.instance.channel.invokeMethod("onOpenNotification", notification);
            JPushPlugin.openNotificationCache.remove(notification);
        }

    }

    static void transmitNotificationReceive(String title, String alert, Map<String, Object> extras) {
        Log.d(TAG, "transmitNotificationReceive " + "title=" + title + "alert=" + alert + "extras=" + extras);

        if (instance == null) {
            return;
        }

        Map<String, Object> notification = new HashMap<>();
        notification.put("title", title);
        notification.put("alert", alert);
        notification.put("extras", extras);
        JPushPlugin.instance.channel.invokeMethod("onReceiveNotification", notification);
    }

    static void transmitReceiveRegistrationId(String rId) {
        Log.d(TAG, "transmitReceiveRegistrationId： " + rId);

        if (instance == null) {
            return;
        }

        JPushPlugin.instance.jpushDidinit = true;

        // try to clean getRid cache
        JPushPlugin.instance.scheduleCache();
    }

}
