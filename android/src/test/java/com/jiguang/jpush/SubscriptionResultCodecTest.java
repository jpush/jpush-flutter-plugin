package com.jiguang.jpush;

import android.os.Bundle;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;
import static org.junit.Assert.*;

@RunWith(RobolectricTestRunner.class)
@Config(manifest = Config.NONE, sdk = 28)
public class SubscriptionResultCodecTest {
    @Test public void subscriptionListsAndNestedVendorBundleKeepTheirTypes() {
        Bundle extra = new Bundle(); Bundle vendor = new Bundle();
        extra.putStringArrayList("requestedChannelIds", new ArrayList<>(Arrays.asList("a", "b")));
        extra.putString("channels", "[]"); extra.putInt("platform", 5);
        vendor.putBoolean("enabled", true); extra.putBundle("vendorExtra", vendor);
        Map<String, Object> encoded = SubscriptionResultCodec.fromBundle(extra);
        assertEquals(Arrays.asList("a", "b"), encoded.get("requestedChannelIds"));
        assertEquals("[]", encoded.get("channels")); assertEquals(5, encoded.get("platform"));
        assertEquals(true, ((Map<?, ?>) encoded.get("vendorExtra")).get("enabled"));
        assertFalse(encoded.containsKey("vendorCode"));
        // Legacy cmd=2012 conversion remains unchanged.
        assertTrue(JPushHelper.bundleToMap(extra).get("requestedChannelIds") instanceof String);
    }
    @Test public void nullAndUnsafeNativeValuesAreNotStringified() {
        assertTrue(SubscriptionResultCodec.fromBundle(null).isEmpty());
        Bundle extra = new Bundle(); extra.putString("intent_action", "hidden");
        extra.putBundle("nested", new Bundle());
        assertFalse(SubscriptionResultCodec.fromBundle(extra).containsKey("intent_action"));
        assertTrue(((Map<?, ?>) SubscriptionResultCodec.fromBundle(extra).get("nested")).isEmpty());
    }
}
