package com.jiguang.jpush;

import android.app.Activity;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterFragmentActivity;

/** Identifies Huawei notification JSON carried by JPush target intents. */
public final class JPushNotificationIntent {
    private static final String TAG = "JPushNotificationIntent";
    private static final String MESSAGE_EXTRA = "JMessageExtra";

    private JPushNotificationIntent() {}

    /**
     * Whether data is Huawei notification JSON accompanied by a JMessageExtra field.
     *
     * This only identifies the SDK transport format; it does not dispatch a click callback.
     * Hosts with a custom embedding can use this in shouldHandleDeeplinking().
     * JMessageExtra is a presence marker; its contents need not equal data.
     */
    public static boolean isHuaweiNotification(Intent intent) {
        if (intent == null) {
            return false;
        }
        try {
            String data = intent.getDataString();
            if (!intent.hasExtra(MESSAGE_EXTRA)
                    || TextUtils.isEmpty(data) || !data.trim().startsWith("{")) {
                return false;
            }
            JSONObject payload = new JSONObject(data);
            Object messageId = payload.opt("msg_id");
            return payload.optInt("rom_type", -1) == 2
                    && (messageId instanceof String || messageId instanceof Number)
                    && !payload.optString("msg_id", "").trim().isEmpty()
                    && payload.opt("n_title") instanceof String
                    && payload.opt("n_content") instanceof String;
        } catch (JSONException | RuntimeException ignored) {
            // Intent extras may fail to unparcel. Do not change data on an uncertain match.
            return false;
        }
    }

    static boolean sanitize(Activity activity, Intent intent) {
        if (!(activity instanceof FlutterActivity)
                && !(activity instanceof FlutterFragmentActivity)) {
            return false;
        }
        if (!isHuaweiNotification(intent)) {
            return false;
        }
        // Keep the existing JMessageExtra and other Intent fields unchanged. Only remove
        // the JSON consumed by Flutter as a route, preserving the original MIME type.
        intent.setDataAndType(null, intent.getType());
        Log.d(TAG, "Removed Huawei notification JSON from Flutter route data");
        return true;
    }
}
