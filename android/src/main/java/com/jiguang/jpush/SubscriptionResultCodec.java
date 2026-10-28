package com.jiguang.jpush;

import android.os.Bundle;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** StandardMessageCodec-safe values for the new cmd=2013 payload only. */
final class SubscriptionResultCodec {
    private SubscriptionResultCodec() { }
    static Map<String, Object> fromBundle(Bundle bundle) {
        Map<String, Object> result = new HashMap<>();
        if (bundle != null) {
            for (String key : bundle.keySet()) {
                if (!key.startsWith("intent_")) result.put(key, encode(bundle.get(key), 0));
            }
        }
        return result;
    }
    private static Object encode(Object value, int depth) {
        if (depth > 16) return null;
        if (value == null || value instanceof Boolean || value instanceof String
                || value instanceof Integer || value instanceof Long || value instanceof Double
                || value instanceof byte[] || value instanceof int[] || value instanceof long[]
                || value instanceof double[]) return value;
        if (value instanceof Bundle) {
            Map<String, Object> result = new HashMap<>();
            Bundle bundle = (Bundle) value;
            for (String key : bundle.keySet()) {
                if (!key.startsWith("intent_")) result.put(key, encode(bundle.get(key), depth + 1));
            }
            return result;
        }
        if (value instanceof List) {
            List<Object> result = new ArrayList<>();
            for (Object item : (List<?>) value) result.add(encode(item, depth + 1));
            return result;
        }
        // Do not stringify arbitrary native objects into callback data.
        return null;
    }
}
