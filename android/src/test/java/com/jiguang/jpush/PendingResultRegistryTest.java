package com.jiguang.jpush;

import org.junit.Test;
import static org.junit.Assert.*;
import java.util.ArrayDeque;
import java.util.concurrent.Executor;
import io.flutter.plugin.common.MethodChannel.Result;

public class PendingResultRegistryTest {
    static class Reply implements Result {
        int count; Object value; String error;
        public void success(Object value) { count++; this.value = value; }
        public void error(String code, String message, Object details) { count++; error = code; }
        public void notImplemented() { fail("Unexpected notImplemented"); }
    }
    static class Queue implements Executor {
        final ArrayDeque<Runnable> tasks = new ArrayDeque<>();
        public synchronized void execute(Runnable task) { tasks.add(task); }
        void drain() { while (!tasks.isEmpty()) tasks.remove().run(); }
    }
    @Test public void concurrentInvocationsCompleteIndependentlyExactlyOnce() throws Exception {
        Queue queue = new Queue(); PendingResultRegistry registry = new PendingResultRegistry(queue);
        registry.attach(); Reply a = new Reply(); Reply b = new Reply();
        PendingResultRegistry.Pending first = registry.start(a), second = registry.start(b);
        Thread t = new Thread(() -> { second.success(4); first.success(0); first.success(5); });
        t.start(); t.join();
        assertEquals(0, a.count); assertEquals(0, b.count);
        queue.drain(); assertEquals(1, a.count); assertEquals(0, a.value);
        assertEquals(1, b.count); assertEquals(4, b.value);
    }
    @Test public void detachCancelsQueuedAndLateCallbacksWithoutReplyingTwice() {
        Queue queue = new Queue(); PendingResultRegistry registry = new PendingResultRegistry(queue);
        registry.attach(); Reply result = new Reply(); PendingResultRegistry.Pending reply = registry.start(result);
        reply.success(0); registry.detach(); registry.attach(); reply.success(0); queue.drain();
        assertEquals(1, result.count); assertEquals("PLUGIN_DETACHED", result.error);
        Reply next = new Reply(); registry.start(next).success(0); queue.drain();
        assertEquals(1, next.count); assertEquals(0, next.value);
    }
    @Test public void nativeErrorsAndDetachedStartsAreExplicit() {
        Queue queue = new Queue(); PendingResultRegistry registry = new PendingResultRegistry(queue);
        Reply detached = new Reply(); registry.start(detached); queue.drain();
        assertEquals("PLUGIN_DETACHED", detached.error);
        registry.attach(); Reply failed = new Reply();
        registry.start(failed).error("NATIVE_EXCEPTION", "failed"); queue.drain();
        assertEquals(1, failed.count); assertEquals("NATIVE_EXCEPTION", failed.error);
    }
}
