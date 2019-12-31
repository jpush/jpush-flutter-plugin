package com.jiguang.jpush;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import cn.jpush.android.api.JPushInterface;
import cn.jpush.android.api.JPushMessage;
import cn.jpush.android.service.JPushMessageReceiver;
import io.flutter.plugin.common.MethodChannel.Result;

public class JPushEventReceiver extends JPushMessageReceiver {

    @Override
    public void onTagOperatorResult(Context context, final JPushMessage jPushMessage) {
        super.onTagOperatorResult(context, jPushMessage);

        final JSONObject resultJson = new JSONObject();

        final int sequence = jPushMessage.getSequence();
        try {
            resultJson.put("sequence", sequence);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        final Result callback = JPushPlugin.instance.callbackMap.get(sequence);//instance.eventCallbackMap.get(sequence);

        if (callback == null) {
            Log.i("JPushPlugin", "Unexpected error, callback is null!");
            return;
        }

        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                if (jPushMessage.getErrorCode() == 0) { // success
                    Set<String> tags = jPushMessage.getTags();
                    List<String> tagList = new ArrayList<>(tags);
                    Map<String, Object> res = new HashMap<>();
                    res.put("tags", tagList);
                    callback.success(res);
                } else {
                    try {
                        resultJson.put("code", jPushMessage.getErrorCode());
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    callback.error(Integer.toString(jPushMessage.getErrorCode()), "", "");
                }

                JPushPlugin.instance.callbackMap.remove(sequence);
            }
        });

    }



    @Override
    public void onCheckTagOperatorResult(Context context, final JPushMessage jPushMessage) {
        super.onCheckTagOperatorResult(context, jPushMessage);



        final int sequence = jPushMessage.getSequence();


        final Result callback = JPushPlugin.instance.callbackMap.get(sequence);

        if (callback == null) {
            Log.i("JPushPlugin", "Unexpected error, callback is null!");
            return;
        }

        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                if (jPushMessage.getErrorCode() == 0) {
                    Set<String> tags = jPushMessage.getTags();
                    List<String> tagList = new ArrayList<>(tags);
                    Map<String, Object> res = new HashMap<>();
                    res.put("tags", tagList);
                    callback.success(res);
                } else {

                    callback.error(Integer.toString(jPushMessage.getErrorCode()), "", "");
                }

                JPushPlugin.instance.callbackMap.remove(sequence);
            }
        });
    }

    @Override
    public void onAliasOperatorResult(Context context, final JPushMessage jPushMessage) {
        super.onAliasOperatorResult(context, jPushMessage);

        final int sequence = jPushMessage.getSequence();

        final Result callback = JPushPlugin.instance.callbackMap.get(sequence);

        if (callback == null) {
            Log.i("JPushPlugin", "Unexpected error, callback is null!");
            return;
        }

        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                if (jPushMessage.getErrorCode() == 0) { // success
                    Map<String, Object> res = new HashMap<>();
                    res.put("alias", (jPushMessage.getAlias() == null)? "" : jPushMessage.getAlias());
                    callback.success(res);

                } else {
                    callback.error(Integer.toString(jPushMessage.getErrorCode()), "", "");
                }

                JPushPlugin.instance.callbackMap.remove(sequence);
            }
        });
    }

    @Override
    public void onNotificationSettingsCheck(Context context, boolean isOn, int source) {
        super.onNotificationSettingsCheck(context, isOn, source);


        HashMap<String, Object> map = new HashMap();
        map.put("isEnabled",isOn);
        JPushPlugin.instance.runMainThread(map,null,"onReceiveNotificationAuthorization");
    }
}
