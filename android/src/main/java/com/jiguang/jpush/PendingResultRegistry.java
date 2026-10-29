package com.jiguang.jpush;

import java.util.Set;
import java.util.Collections;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executor;
import java.util.concurrent.atomic.AtomicBoolean;
import io.flutter.plugin.common.MethodChannel.Result;

/** Per-engine, per-invocation replies. All replies are dispatched on the main thread. */
final class PendingResultRegistry {
    private final Executor dispatcher;
    private final Set<Pending> pending = Collections.newSetFromMap(new ConcurrentHashMap<Pending, Boolean>());
    private volatile boolean attached;
    private volatile long generation;

    PendingResultRegistry(Executor dispatcher) { this.dispatcher = dispatcher; }

    synchronized void attach() { generation++; attached = true; }

    synchronized Pending start(Result result) {
        Pending reply = new Pending(result, generation);
        pending.add(reply);
        if (!attached) reply.error("PLUGIN_DETACHED", "Plugin is detached");
        return reply;
    }

    synchronized void detach() {
        attached = false;
        for (Pending reply : pending.toArray(new Pending[0])) {
            reply.error("PLUGIN_DETACHED", "Plugin is detached");
        }
    }

    final class Pending {
        private Result result;
        private final long ownerGeneration;
        private final AtomicBoolean completed = new AtomicBoolean();

        Pending(Result result, long ownerGeneration) {
            this.result = result;
            this.ownerGeneration = ownerGeneration;
        }
        void success(Object value) { finish(value, null, null); }
        void error(String code, String message) { finish(null, code, message); }

        private void finish(Object value, String code, String message) {
            dispatcher.execute(() -> {
                if (!completed.compareAndSet(false, true)) return;
                pending.remove(this);
                Result result = this.result;
                this.result = null;
                if (!attached || ownerGeneration != generation) {
                    result.error("PLUGIN_DETACHED", "Plugin is detached", null);
                } else if (code != null) {
                    result.error(code, message, null);
                } else {
                    result.success(value);
                }
            });
        }
    }
}
