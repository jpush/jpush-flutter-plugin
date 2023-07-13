package com.jiguang.jpush;

import android.app.Activity;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
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
import cn.jiguang.api.utils.JCollectionAuth;
import cn.jpush.android.api.JPushInterface;
import cn.jpush.android.api.NotificationMessage;
import cn.jpush.android.data.JPushLocalNotification;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * JPushPlugin
 */
public class JPushPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private static String TAG = "| JPUSH | Flutter | Android | ";
    private Context context;
    private Activity mActivity;
    private int sequence;
    public JPushPlugin() {
        this.sequence = 0;
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
        MethodChannel  channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "jpush");
        channel.setMethodCallHandler(this);
         context = flutterPluginBinding.getApplicationContext();
        JPushHelper.getInstance().setMethodChannel(channel);
        JPushHelper.getInstance().setContext(context);
    }
    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        if(activityPluginBinding!=null){
            mActivity = activityPluginBinding.getActivity();
        }
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    }

    @Override
    public void onDetachedFromActivity() {

    }
    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        MethodChannel  channel =JPushHelper.getInstance().getChannel();
        if(channel!=null){
            channel.setMethodCallHandler(null);
        }
        JPushHelper.getInstance().setDartIsReady(false);
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
        } else if (call.method.equals("getAlias")) {
            getAlias(call, result);
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
        } else if (call.method.equals("setAuth")) {
            setAuth(call, result);
        } else if (call.method.equals("testCountryCode")) {
            testCountryCode(call, result);
        }else if (call.method.equals("enableAutoWakeup")) {
            enableAutoWakeup(call, result);
        } else if (call.method.equals("setLbsEnable")) {
            setLbsEnable(call, result);
        }else if (call.method.equals("setChannelAndSound")) {
            setChannelAndSound(call, result);
        }else if (call.method.equals("requestRequiredPermission")) {
            requestRequiredPermission(call, result);
        } else {
            result.notImplemented();
        }
    }
    public void requestRequiredPermission(MethodCall call, Result result){
        JPushInterface.requestRequiredPermission(mActivity);
    }
    public void setChannelAndSound(MethodCall call, Result result) {
        HashMap<String, Object> readableMap = call.arguments();
        if (readableMap == null) {
            return;
        }
        String channel = (String)readableMap.get("channel");
        String channelId = (String)readableMap.get("channel_id");
        String sound = (String)readableMap.get("sound");
        try {
            NotificationManager manager= (NotificationManager) context.getSystemService("notification");
            if(Build.VERSION.SDK_INT<26){
                return;
            }
            if(TextUtils.isEmpty(channel)||TextUtils.isEmpty(channelId)){
                return;
            }
            NotificationChannel channel1=new NotificationChannel(channelId,channel, NotificationManager.IMPORTANCE_HIGH);
            if(!TextUtils.isEmpty(sound)){
                channel1.setSound(Uri.parse("android.resource://"+context.getPackageName()+"/raw/"+sound),null);
            }
            manager.createNotificationChannel(channel1);
            JPushInterface.setChannel(context,channel);
            Log.d(TAG,"setChannelAndSound channelId="+channelId+" channel="+channel+" sound="+sound);

        }catch (Throwable throwable){
        }
    }
    private void setLbsEnable(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        if (map == null) {
            return;
        }
        Boolean enable = (Boolean) map.get("enable");
        if (enable == null) {
            enable = true;
        }
        JPushInterface.setLbsEnable(context,enable);
    }

    private void setAuth(MethodCall call, Result result){
        HashMap<String, Object> map = call.arguments();
        if (map == null) {
            return;
        }
        Boolean enable = (Boolean) map.get("enable");
        if (enable == null) {
            enable = false;
        }
        JCollectionAuth.setAuth(context,enable);
    }
    private void testCountryCode(MethodCall call, Result result){
        String code = call.arguments();
        Log.d(TAG,"testCountryCode code="+code);
        JCoreInterface.testCountryCode(code);
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
    private void enableAutoWakeup(MethodCall call, Result result) {
        HashMap<String, Object> map = call.arguments();
        if (map == null) {
            return;
        }
        Boolean enable = (Boolean) map.get("enable");
        if (enable == null) {
            enable = false;
        }
        JCollectionAuth.enableAutoWakeup(context,enable);
    }



    public void setup(MethodCall call, Result result) {
        Log.d(TAG, "setup :" + call.arguments);

        HashMap<String, Object> map = call.arguments();
        boolean debug = (boolean) map.get("debug");
        JPushInterface.setDebugMode(debug);

        JPushInterface.init(context);            // 初始化 JPush
        JPushInterface.setNotificationCallBackEnable(context, true);
        String channel = (String) map.get("channel");
        JPushInterface.setChannel(context, channel);
        JPushHelper.getInstance().setDartIsReady(true);

        // try to clean getRid cache
        scheduleCache();
    }

    public void scheduleCache() {
        Log.d(TAG, "scheduleCache:");
      JPushHelper.getInstance().dispatchNotification();
      JPushHelper.getInstance().dispatchRid();
    }

    public void setTags(MethodCall call, Result result) {
        Log.d(TAG, "setTags：");

        List<String> tagList = call.arguments();
        Set<String> tags = new HashSet<>(tagList);
        sequence += 1;
        JPushHelper.getInstance().addCallback(sequence,result);
        JPushInterface.setTags(context, sequence, tags);
    }

    public void cleanTags(MethodCall call, Result result) {
        Log.d(TAG, "cleanTags:");

        sequence += 1;
        JPushHelper.getInstance().addCallback(sequence,result);
        JPushInterface.cleanTags(context, sequence);
    }

    public void addTags(MethodCall call, Result result) {
        Log.d(TAG, "addTags: " + call.arguments);

        List<String> tagList = call.arguments();
        Set<String> tags = new HashSet<>(tagList);
        sequence += 1;
        JPushHelper.getInstance().addCallback(sequence,result);
        JPushInterface.addTags(context, sequence, tags);
    }

    public void deleteTags(MethodCall call, Result result) {
        Log.d(TAG, "deleteTags： " + call.arguments);

        List<String> tagList = call.arguments();
        Set<String> tags = new HashSet<>(tagList);
        sequence += 1;
        JPushHelper.getInstance().addCallback(sequence,result);
        JPushInterface.deleteTags(context, sequence, tags);
    }

    public void getAllTags(MethodCall call, Result result) {
        Log.d(TAG, "getAllTags： ");

        sequence += 1;
        JPushHelper.getInstance().addCallback(sequence,result);
        JPushInterface.getAllTags(context, sequence);
    }
    public void getAlias(MethodCall call, Result result) {
        Log.d(TAG, "getAlias： ");

        sequence += 1;
        JPushHelper.getInstance().addCallback(sequence,result);
        JPushInterface.getAlias(context, sequence);
    }

    public void setAlias(MethodCall call, Result result) {
        Log.d(TAG, "setAlias: " + call.arguments);

        String alias = call.arguments();
        sequence += 1;
        JPushHelper.getInstance().addCallback(sequence,result);
        JPushInterface.setAlias(context, sequence, alias);
    }

    public void deleteAlias(MethodCall call, Result result) {
        Log.d(TAG, "deleteAlias:");

        String alias = call.arguments();
        sequence += 1;
        JPushHelper.getInstance().addCallback(sequence,result);
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
            JPushHelper.getInstance().addRid(result);
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

        JPushHelper.getInstance().runMainThread(map, result, null);
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
                JPushHelper.getInstance().transmitReceiveRegistrationId(rId);

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
            String title = intent.getStringExtra(JPushInterface.EXTRA_TITLE);
            Map<String, Object> extras = getNotificationExtras(intent);
            JPushHelper.getInstance().transmitMessageReceive(msg, title,extras);
        }

        private void handlingNotificationOpen(Context context, Intent intent) {
            Log.d(TAG, "handlingNotificationOpen " + intent.getAction());

            String title = intent.getStringExtra(JPushInterface.EXTRA_NOTIFICATION_TITLE);
            String alert = intent.getStringExtra(JPushInterface.EXTRA_ALERT);
            Map<String, Object> extras = getNotificationExtras(intent);
            JPushHelper.getInstance().transmitNotificationOpen(title, alert, extras);
        }

        private void handlingNotificationReceive(Context context, Intent intent) {
            Log.d(TAG, "handlingNotificationReceive " + intent.getAction());

            String title = intent.getStringExtra(JPushInterface.EXTRA_NOTIFICATION_TITLE);
            String alert = intent.getStringExtra(JPushInterface.EXTRA_ALERT);
            Map<String, Object> extras = getNotificationExtras(intent);
            JPushHelper.getInstance().transmitNotificationReceive(title, alert, extras);
        }

        private Map<String, Object> getNotificationExtras(Intent intent) {
            Map<String, Object> extrasMap = new HashMap<String, Object>();
            Bundle extras = intent.getExtras();
            for (String key : extras.keySet()) {
                if (!IGNORED_EXTRAS_KEYS.contains(key)) {
                    if (key.equals(JPushInterface.EXTRA_NOTIFICATION_ID)) {
                        extrasMap.put(key, intent.getIntExtra(key, 0));
                    } else {
                        extrasMap.put(key, extras.get(key));
                    }
                }
            }
            return extrasMap;
        }
    }




}
