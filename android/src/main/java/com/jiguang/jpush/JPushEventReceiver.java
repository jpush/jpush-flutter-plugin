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

import cn.jpush.android.api.JPushMessage;
import cn.jpush.android.service.JPushMessageReceiver;
import io.flutter.plugin.common.MethodChannel.Result;

public class JPushEventReceiver extends JPushMessageReceiver {
    private Handler handler = new Handler(Looper.getMainLooper());

    @Override
    public void onTagOperatorResult(Context context, final JPushMessage jPushMessage) {
        super.onTagOperatorResult(context, jPushMessage);

        JSONObject resultJson = new JSONObject();

        int sequence = jPushMessage.getSequence();
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

        if (jPushMessage.getErrorCode() == 0) { // success
            Set<String> tags = jPushMessage.getTags();
            List<String> tagList = new ArrayList<>(tags);
            final Map<String, Object> res = new HashMap<>();
            res.put("tags", tagList);
            handler.post(new Runnable() {
                @Override
                public void run() {
                    callback.success(res);
                }
            });
        } else {
            try {
                resultJson.put("code", jPushMessage.getErrorCode());
            } catch (JSONException e) {
                e.printStackTrace();
            }
            handler.post(new Runnable() {
                             @Override
                             public void run() {
                                 callback.error(Integer.toString(jPushMessage.getErrorCode()), "", "");
                             }
                         }
            );
        }

        JPushPlugin.instance.callbackMap.remove(sequence);
    }


    @Override
    public void onCheckTagOperatorResult(Context context, final JPushMessage jPushMessage) {
        super.onCheckTagOperatorResult(context, jPushMessage);


        int sequence = jPushMessage.getSequence();


        final Result callback = JPushPlugin.instance.callbackMap.get(sequence);

        if (callback == null) {
            Log.i("JPushPlugin", "Unexpected error, callback is null!");
            return;
        }

        if (jPushMessage.getErrorCode() == 0) {
            Set<String> tags = jPushMessage.getTags();
            List<String> tagList = new ArrayList<>(tags);
            final Map<String, Object> res = new HashMap<>();
            res.put("tags", tagList);
            handler.post(new Runnable() {
                @Override
                public void run() {
                    callback.success(res);
                }
            });
        } else {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    callback.error(Integer.toString(jPushMessage.getErrorCode()), "", "");
                }
            });
        }

        JPushPlugin.instance.callbackMap.remove(sequence);
    }

    @Override
    public void onAliasOperatorResult(Context context, final JPushMessage jPushMessage) {
        super.onAliasOperatorResult(context, jPushMessage);

        int sequence = jPushMessage.getSequence();

        final Result callback = JPushPlugin.instance.callbackMap.get(sequence);

        if (callback == null) {
            Log.i("JPushPlugin", "Unexpected error, callback is null!");
            return;
        }

        if (jPushMessage.getErrorCode() == 0) { // success
            final Map<String, Object> res = new HashMap<>();
            res.put("alias", (jPushMessage.getAlias() == null) ? "" : jPushMessage.getAlias());
            handler.post(new Runnable() {
                @Override
                public void run() {
                    callback.success(res);
                }
            });
        } else {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    callback.error(Integer.toString(jPushMessage.getErrorCode()), "", "");
                }
            });
        }

        JPushPlugin.instance.callbackMap.remove(sequence);
    }
}
