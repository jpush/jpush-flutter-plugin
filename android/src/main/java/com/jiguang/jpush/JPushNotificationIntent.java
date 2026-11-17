package com.jiguang.jpush;

import android.app.Activity;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterFragmentActivity;

/** Identifies JSON-shaped notification data carried by JPush target intents. */
public final class JPushNotificationIntent {
    private static final String TAG = "JPushNotificationIntent";
    private static final String MESSAGE_EXTRA = "JMessageExtra";

    private JPushNotificationIntent() {}

    /**
     * Whether data looks like a JSON object and is marked by JMessageExtra.
     *
     * This is a route guard, not notification payload validation or click dispatch.
     * Hosts with a custom embedding can use this in shouldHandleDeeplinking().
     * JMessageExtra is a presence marker; its contents need not equal data.
     */
    public static boolean isJPushNotificationData(Intent intent) {
        if (intent == null) {
            return false;
        }
        try {
            if (!intent.hasExtra(MESSAGE_EXTRA)) {
                return false;
            }
            String data = intent.getDataString();
            return !TextUtils.isEmpty(data) && data.trim().startsWith("{");
        } catch (RuntimeException ignored) {
            // Intent extras may fail to unparcel. Do not change data on an uncertain match.
            return false;
        }
    }

    static boolean sanitize(Activity activity, Intent intent) {
        if (!(activity instanceof FlutterActivity)
                && !(activity instanceof FlutterFragmentActivity)) {
            return false;
        }
        if (!isJPushNotificationData(intent)) {
            return false;
        }
        // Keep the existing JMessageExtra and other Intent fields unchanged. Only remove
        // the JSON consumed by Flutter as a route, preserving the original MIME type.
        intent.setDataAndType(null, intent.getType());
        Log.d(TAG, "Removed JPush notification JSON from Flutter route data");
        return true;
    }
}
