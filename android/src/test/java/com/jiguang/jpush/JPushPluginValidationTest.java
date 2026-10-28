package com.jiguang.jpush;

import android.app.Activity;
import java.lang.reflect.Field;
import java.lang.reflect.Proxy;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.Robolectric;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.RuntimeEnvironment;
import org.robolectric.annotation.Config;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import static org.junit.Assert.*;

@RunWith(RobolectricTestRunner.class)
@Config(manifest = Config.NONE, sdk = 28)
public class JPushPluginValidationTest {
    private JPushPlugin attached() throws Exception {
        JPushPlugin plugin = new JPushPlugin();
        Field context = JPushPlugin.class.getDeclaredField("context");
        context.setAccessible(true); context.set(plugin, RuntimeEnvironment.getApplication());
        return plugin;
    }
    @Test public void directChannelCannotBypassListValidation() throws Exception {
        JPushPlugin plugin = attached();
        Object[] invalid = {null, "not-a-list", Arrays.asList(), Arrays.asList("a", "a"),
            Arrays.asList(" "), Arrays.asList(7), Arrays.asList("a", "b", "c", "d")};
        for (Object ids : invalid) {
            Map<String, Object> args = new HashMap<>(); args.put("channelIds", ids);
            PendingResultRegistryTest.Reply reply = new PendingResultRegistryTest.Reply();
            plugin.onMethodCall(new MethodCall("requestSubscribeChannels", args), reply);
            assertEquals(1, reply.count); assertEquals("INVALID_ARGUMENT", reply.error);
        }
        PendingResultRegistryTest.Reply malformed = new PendingResultRegistryTest.Reply();
        plugin.onMethodCall(new MethodCall("requestSubscribeChannels", "bad-envelope"), malformed);
        assertEquals("INVALID_ARGUMENT", malformed.error);
    }
    @Test public void validIdsWithoutActivityFailBeforeSdkDispatch() throws Exception {
        Map<String, Object> args = new HashMap<>(); args.put("channelIds", Arrays.asList("a"));
        PendingResultRegistryTest.Reply reply = new PendingResultRegistryTest.Reply();
        attached().onMethodCall(new MethodCall("requestSubscribeChannels", args), reply);
        assertEquals(1, reply.count); assertEquals("NO_ACTIVITY", reply.error);
        PendingResultRegistryTest.Reply detached = new PendingResultRegistryTest.Reply();
        new JPushPlugin().onMethodCall(new MethodCall("requestSubscribeChannels", args), detached);
        assertEquals("PLUGIN_DETACHED", detached.error);
    }
    @Test public void configurationDetachNeverRetainsTheOldActivity() throws Exception {
        JPushPlugin plugin = attached(); Activity first = Robolectric.buildActivity(Activity.class).setup().get();
        Activity second = Robolectric.buildActivity(Activity.class).setup().get();
        Field activity = JPushPlugin.class.getDeclaredField("mActivity"); activity.setAccessible(true);
        plugin.onAttachedToActivity(binding(first)); assertSame(first, activity.get(plugin));
        plugin.onDetachedFromActivityForConfigChanges(); assertNull(activity.get(plugin));
        plugin.onReattachedToActivityForConfigChanges(binding(second)); assertSame(second, activity.get(plugin));
        plugin.onDetachedFromActivity(); assertNull(activity.get(plugin));
    }
    private ActivityPluginBinding binding(Activity activity) {
        return (ActivityPluginBinding) Proxy.newProxyInstance(ActivityPluginBinding.class.getClassLoader(),
            new Class<?>[]{ActivityPluginBinding.class}, (proxy, method, args) -> {
                if (method.getName().equals("getActivity")) return activity;
                if (method.getName().equals("toString")) return "test binding";
                return null;
            });
    }
}
