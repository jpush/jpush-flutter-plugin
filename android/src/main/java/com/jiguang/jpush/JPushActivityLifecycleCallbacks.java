package com.jiguang.jpush;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

import java.lang.ref.WeakReference;

/** Runs before standard Flutter hosts read an Intent's initial route. */
final class JPushActivityLifecycleCallbacks implements Application.ActivityLifecycleCallbacks {
    private static WeakReference<Application> registeredApplication = new WeakReference<>(null);

    static synchronized void register(Application application) {
        if (registeredApplication.get() == application) {
            return;
        }
        application.registerActivityLifecycleCallbacks(new JPushActivityLifecycleCallbacks());
        registeredApplication = new WeakReference<>(application);
    }

    @Override
    public void onActivityPreCreated(Activity activity, Bundle savedInstanceState) {
        // Android 29+: handle before any Activity onCreate implementation.
        JPushNotificationIntent.sanitize(activity, activity.getIntent());
    }

    @Override
    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
        // Older Android: standard FlutterActivity calls Activity.super.onCreate before
        // creating its engine. onAttachedToActivity is too late on that cold-start path.
        // Calling twice on Android 29+ is harmless because data has already been removed.
        JPushNotificationIntent.sanitize(activity, activity.getIntent());
    }

    @Override public void onActivityStarted(Activity activity) {}
    @Override public void onActivityResumed(Activity activity) {}
    @Override public void onActivityPaused(Activity activity) {}
    @Override public void onActivityStopped(Activity activity) {}
    @Override public void onActivitySaveInstanceState(Activity activity, Bundle outState) {}
    @Override public void onActivityDestroyed(Activity activity) {}
}
