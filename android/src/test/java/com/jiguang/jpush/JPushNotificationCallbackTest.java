package com.jiguang.jpush;

import android.content.Intent;
import android.os.Looper;
import cn.jpush.android.api.NotificationMessage;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.Shadows;
import org.robolectric.annotation.Config;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMethodCodec;
import static org.junit.Assert.*;

@RunWith(RobolectricTestRunner.class)
@Config(manifest = Config.NONE, sdk = 28)
public class JPushNotificationCallbackTest {
    @Test public void clearingRouteDataPreservesOneCachedNativeClickAndItsCustomerExtras() {
        JPushHelper helper = JPushHelper.getInstance();
        RecordingMessenger messenger = new RecordingMessenger();
        helper.setMethodChannel(new MethodChannel(messenger, "jpush"), "test");
        helper.setDartIsReady(true);
        helper.dispatchNotification();
        Shadows.shadowOf(Looper.getMainLooper()).idle();
        messenger.calls.clear();
        helper.setMethodChannel(null, null);
        helper.setDartIsReady(false);
        try {
            NotificationMessage message = new NotificationMessage();
            message.msgId = "123456789";
            message.notificationTitle = "Demo";
            message.notificationContent = "Notification";
            message.notificationExtras = "{\"extra\":\"{\\\"source\\\":1}\"}";
            new JPushEventReceiver().onNotifyMessageOpened(null, message);
            Shadows.shadowOf(Looper.getMainLooper()).idle();
            assertTrue(messenger.calls.isEmpty());

            Intent intent = JPushNotificationIntentTest.notificationIntent();
            assertTrue(JPushNotificationIntent.sanitize(new FlutterActivity(), intent));
            assertEquals(JPushNotificationIntentTest.PAYLOAD, intent.getStringExtra("JMessageExtra"));
            helper.setMethodChannel(new MethodChannel(messenger, "jpush"), "test");
            helper.setDartIsReady(true);
            helper.dispatchNotification();
            Shadows.shadowOf(Looper.getMainLooper()).idle();
            assertEquals(1, messenger.calls.size());
            MethodCall call = messenger.calls.get(0);
            assertEquals("onOpenNotification", call.method);
            Map<?, ?> payload = (Map<?, ?>) call.arguments;
            assertEquals("Demo", payload.get("title"));
            assertEquals("Notification", payload.get("alert"));
            Map<?, ?> extras = (Map<?, ?>) payload.get("extras");
            assertEquals("123456789", extras.get("cn.jpush.android.MSG_ID"));
            Map<?, ?> custom = (Map<?, ?>) extras.get("cn.jpush.android.EXTRA");
            assertEquals("{\"source\":1}", custom.get("extra"));

            helper.dispatchNotification();
            Shadows.shadowOf(Looper.getMainLooper()).idle();
            assertEquals(1, messenger.calls.size());
        } finally {
            helper.setMethodChannel(null, null);
            helper.setDartIsReady(false);
        }
    }

    private static final class RecordingMessenger implements BinaryMessenger {
        final List<MethodCall> calls = new ArrayList<>();
        @Override public void send(String channel, ByteBuffer message) { send(channel, message, null); }
        @Override public void send(String channel, ByteBuffer message, BinaryReply callback) {
            assertEquals("jpush", channel);
            ByteBuffer copy = message.duplicate();
            copy.flip();
            calls.add(StandardMethodCodec.INSTANCE.decodeMethodCall(copy));
        }
        @Override public void setMessageHandler(String channel, BinaryMessageHandler handler) {}
    }
}
