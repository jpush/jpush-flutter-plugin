package com.jiguang.jpush;

import cn.jpush.android.api.VoipDataMessage;
import java.util.Map;
import org.junit.Test;
import static org.junit.Assert.*;

public class VoipPayloadTest {
    @Test public void preservesSupportStatusAsIntegerIncludingUnknownValues() {
        VoipDataMessage message = new VoipDataMessage();
        message.setMessageId("fixture"); message.setExtraData("{}"); message.setPlatform((byte) 1);
        for (int status : new int[]{0, 1, -99, Integer.MAX_VALUE}) {
            message.setVoipSupportStatus(status);
            Map<String,Object> payload = JPushHelper.voipPayload(message);
            assertEquals(Integer.valueOf(status), payload.get("voipSupportStatus"));
            assertEquals("fixture", payload.get("messageId"));
            assertEquals("{}", payload.get("extraData"));
            assertEquals(Integer.valueOf(1), payload.get("platform"));
        }
    }
}
