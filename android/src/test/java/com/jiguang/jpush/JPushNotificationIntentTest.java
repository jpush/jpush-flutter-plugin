package com.jiguang.jpush;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Intent;
import android.net.Uri;
import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.List;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry.NewIntentListener;
import static org.junit.Assert.*;

@RunWith(RobolectricTestRunner.class)
@Config(manifest = Config.NONE, sdk = 28)
public class JPushNotificationIntentTest {
    static final String PAYLOAD = "{\"n_extras\":{\"extra\":\"{\\\"source\\\":1}\"},"
            + "\"n_title\":\"Demo\",\"n_content\":\"Notification\","
            + "\"msg_id\":123456789,\"rom_type\":2}";

    static Intent notificationIntent() {
        return new Intent(Intent.ACTION_MAIN, Uri.parse(PAYLOAD))
                .putExtra("JMessageExtra", PAYLOAD);
    }

    @Test public void recognitionDoesNotModifyTheIntentUsedByHostDeepLinkChecks() {
        Intent intent = notificationIntent();
        assertTrue(JPushNotificationIntent.isJPushNotificationData(intent));
        assertEquals(PAYLOAD, intent.getDataString());
        assertEquals(PAYLOAD, intent.getStringExtra("JMessageExtra"));
    }

    @Test public void preservesPayloadMimeTypeAndAllOtherLaunchFields() {
        Intent intent = notificationIntent()
                .setDataAndType(Uri.parse(PAYLOAD), "application/json")
                .setComponent(new ComponentName("example", "example.MainActivity"))
                .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP)
                .addCategory(Intent.CATEGORY_LAUNCHER)
                .putExtra("route", "/splash").putExtra("customer", 7);
        assertTrue(JPushNotificationIntent.sanitize(new FlutterActivity(), intent));
        assertNull(intent.getData());
        assertEquals(PAYLOAD, intent.getStringExtra("JMessageExtra"));
        assertEquals("application/json", intent.getType());
        assertEquals("example.MainActivity", intent.getComponent().getClassName());
        assertEquals(Intent.ACTION_MAIN, intent.getAction());
        assertEquals(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP, intent.getFlags());
        assertTrue(intent.hasCategory(Intent.CATEGORY_LAUNCHER));
        assertEquals("/splash", intent.getStringExtra("route"));
        assertEquals(7, intent.getIntExtra("customer", -1));
        assertFalse(JPushNotificationIntent.sanitize(new FlutterActivity(), intent));
    }

    @Test public void neverChangesRealDeepLinksEvenWhenTheyCarryPushExtras() {
        for (String url : new String[]{"app://order/detail?id=123", "https://example.com/order/123"}) {
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url))
                    .putExtra("JMessageExtra", PAYLOAD);
            assertFalse(JPushNotificationIntent.sanitize(new FlutterActivity(), intent));
            assertEquals(url, intent.getDataString());
            assertEquals(PAYLOAD, intent.getStringExtra("JMessageExtra"));
        }
    }

    @Test public void uncertainPayloadsRemainUntouched() {
        List<Intent> inputs = new ArrayList<>();
        inputs.add(new Intent());
        inputs.add(new Intent(Intent.ACTION_MAIN, Uri.parse(PAYLOAD)));
        for (String json : new String[]{
                "", "   ", "[]", "null", "app://order/123", "https://example.com/order/123"}) {
            inputs.add(new Intent(Intent.ACTION_MAIN, Uri.parse(json)).putExtra("JMessageExtra", json));
        }
        for (Intent intent : inputs) {
            String original = intent.getDataString();
            assertFalse(JPushNotificationIntent.sanitize(new FlutterActivity(), intent));
            assertEquals(original, intent.getDataString());
        }
        assertFalse(JPushNotificationIntent.isJPushNotificationData(null));
    }

    @Test public void routeFilteringDoesNotDependOnNotificationBusinessFieldsOrJsonParsing() {
        for (String json : new String[]{"{}", "{broken", " \n {\"customer\":1}",
                "{\"rom_type\":1}", "{\"msg_id\":null,\"n_title\":null}"}) {
            Intent intent = new Intent(Intent.ACTION_MAIN, Uri.parse(json))
                    .putExtra("JMessageExtra", "marker");
            assertTrue(JPushNotificationIntent.sanitize(new FlutterActivity(), intent));
            assertNull(intent.getData());
            assertEquals("marker", intent.getStringExtra("JMessageExtra"));
        }
    }

    @Test public void extraPresenceIsEnoughAndItsExistingValueIsNeverReplaced() {
        Intent different = notificationIntent().putExtra("JMessageExtra", "{\"customer\":1}");
        assertTrue(JPushNotificationIntent.sanitize(new FlutterActivity(), different));
        assertNull(different.getData());
        assertEquals("{\"customer\":1}", different.getStringExtra("JMessageExtra"));

        Intent nonString = notificationIntent().putExtra("JMessageExtra", 7);
        assertTrue(JPushNotificationIntent.isJPushNotificationData(nonString));
        assertTrue(JPushNotificationIntent.sanitize(new FlutterActivity(), nonString));
        assertEquals(7, nonString.getIntExtra("JMessageExtra", -1));
    }

    @Test public void nativeTransitActivitiesAreNotModified() {
        Intent intent = notificationIntent();
        assertFalse(JPushNotificationIntent.sanitize(new Activity(), intent));
        assertEquals(PAYLOAD, intent.getDataString());
    }

    @Test public void lifecycleFallbackHandlesFlutterHostAndFragmentHostIdempotently() {
        JPushActivityLifecycleCallbacks callbacks = new JPushActivityLifecycleCallbacks();
        for (Activity activity : new Activity[]{new FlutterActivity(), new FlutterFragmentActivity()}) {
            Intent intent = notificationIntent();
            activity.setIntent(intent);
            callbacks.onActivityCreated(activity, null);
            assertNull(intent.getData());
            callbacks.onActivityCreated(activity, null);
            assertEquals(PAYLOAD, intent.getStringExtra("JMessageExtra"));
        }
    }

    @Test @Config(sdk = 34)
    public void preCreateCleansTheIntentBeforeTheCreatedCallback() {
        Activity activity = new FlutterActivity();
        activity.setIntent(notificationIntent());
        JPushActivityLifecycleCallbacks callbacks = new JPushActivityLifecycleCallbacks();
        callbacks.onActivityPreCreated(activity, null);
        assertNull(activity.getIntent().getData());
        callbacks.onActivityCreated(activity, null);
        assertEquals(PAYLOAD, activity.getIntent().getStringExtra("JMessageExtra"));
    }

    @Test public void warmIntentIsHandledSynchronouslyAndListenerIsRemovedOnDetach() {
        JPushPlugin plugin = new JPushPlugin();
        Binding first = new Binding(new FlutterActivity());
        plugin.onAttachedToActivity(first.proxy());
        assertEquals(1, first.listeners.size());
        Intent incoming = notificationIntent();
        assertFalse(first.listeners.get(0).onNewIntent(incoming));
        assertNull(incoming.getData());
        assertEquals(PAYLOAD, incoming.getStringExtra("JMessageExtra"));

        plugin.onDetachedFromActivityForConfigChanges();
        assertTrue(first.listeners.isEmpty());
        Binding second = new Binding(new FlutterActivity());
        plugin.onReattachedToActivityForConfigChanges(second.proxy());
        plugin.onAttachedToActivity(second.proxy());
        assertEquals(1, second.listeners.size());
        plugin.onDetachedFromActivity();
        assertTrue(second.listeners.isEmpty());
    }

    private static final class Binding {
        final Activity activity;
        final List<NewIntentListener> listeners = new ArrayList<>();
        Binding(Activity activity) { this.activity = activity; }
        ActivityPluginBinding proxy() {
            return (ActivityPluginBinding) Proxy.newProxyInstance(
                    ActivityPluginBinding.class.getClassLoader(),
                    new Class<?>[]{ActivityPluginBinding.class}, (proxy, method, args) -> {
                        switch (method.getName()) {
                            case "getActivity": return activity;
                            case "addOnNewIntentListener": listeners.add((NewIntentListener) args[0]); break;
                            case "removeOnNewIntentListener": listeners.remove(args[0]); break;
                            case "toString": return "notification test binding";
                        }
                        return null;
                    });
        }
    }
}
