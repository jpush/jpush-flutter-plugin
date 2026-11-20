package com.jiguang.jpush;

import android.content.Context;
import cn.jiguang.api.JCoreInterface;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import java.lang.reflect.Field;
import java.util.Arrays;
import java.util.Locale;
import org.junit.Before;
import org.junit.Test;
import org.mockito.MockedStatic;
import static org.mockito.Mockito.*;

public class CountryCodeTest {
    private JPushPlugin plugin;
    private Context context;
    private Result result;

    @Before
    public void setUp() throws Exception {
        plugin = new JPushPlugin();
        context = mock(Context.class);
        result = mock(Result.class);
        Field field = JPushPlugin.class.getDeclaredField("context");
        field.setAccessible(true);
        field.set(plugin, context);
    }

    @Test
    public void dispatchesToPersistentApiWithLocaleIndependentCode() {
        Locale previous = Locale.getDefault();
        Locale.setDefault(new Locale("tr", "TR"));
        try (MockedStatic<JCoreInterface> sdk = mockStatic(JCoreInterface.class)) {
            plugin.onMethodCall(new MethodCall("setCountryCode", " in "), result);
            sdk.verify(() -> JCoreInterface.setCountryCode(context, "IN"));
            sdk.verifyNoMoreInteractions();
            verify(result).success(null);
            verifyNoMoreInteractions(result);
        } finally {
            Locale.setDefault(previous);
        }
    }

    @Test
    public void rejectsBadArgumentsWithoutCallingSdk() {
        try (MockedStatic<JCoreInterface> sdk = mockStatic(JCoreInterface.class)) {
            for (Object code : Arrays.asList(null, 12, Arrays.asList("US"), "", "USA", "u1", "ß", "中国")) {
                Result rejected = mock(Result.class);
                plugin.onMethodCall(new MethodCall("setCountryCode", code), rejected);
                verify(rejected).error("INVALID_ARGUMENT", "code must be two ASCII letters", null);
                verifyNoMoreInteractions(rejected);
            }
            sdk.verifyNoInteractions();
        }
    }

    @Test
    public void surfacesSynchronousSdkFailureExactlyOnce() {
        try (MockedStatic<JCoreInterface> sdk = mockStatic(JCoreInterface.class)) {
            sdk.when(() -> JCoreInterface.setCountryCode(context, "US"))
                .thenThrow(new IllegalStateException("test failure"));
            plugin.onMethodCall(new MethodCall("setCountryCode", "US"), result);
            verify(result).error("NATIVE_ERROR", "Could not submit country code to the SDK", null);
            verifyNoMoreInteractions(result);
        }
    }

    @Test
    public void rejectsMissingEngineContext() {
        new JPushPlugin().onMethodCall(new MethodCall("setCountryCode", "US"), result);
        verify(result).error("NOT_ATTACHED", "Plugin is not attached to an engine", null);
        verifyNoMoreInteractions(result);
    }

    @Test
    public void leavesTemporaryApiUnchanged() {
        try (MockedStatic<JCoreInterface> sdk = mockStatic(JCoreInterface.class)) {
            plugin.onMethodCall(new MethodCall("testCountryCode", "us"), result);
            sdk.verify(() -> JCoreInterface.testCountryCode(context, "us"));
            sdk.verifyNoMoreInteractions();
            verifyNoInteractions(result);
        }
    }
}
