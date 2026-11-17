package com.jiguang.jpush;

import android.app.Application;
import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;

/** Registers an early lifecycle listener without initializing JPush or starting network work. */
public final class JPushInitProvider extends ContentProvider {
    @Override
    public boolean onCreate() {
        Context context = getContext();
        Context application = context == null ? null : context.getApplicationContext();
        if (!(application instanceof Application)) {
            return false;
        }
        JPushActivityLifecycleCallbacks.register((Application) application);
        return true;
    }

    @Override
    public Cursor query(Uri uri, String[] projection, String selection,
                        String[] selectionArgs, String sortOrder) {
        throw new UnsupportedOperationException("Initialization only");
    }

    @Override public String getType(Uri uri) { return null; }
    @Override public Uri insert(Uri uri, ContentValues values) {
        throw new UnsupportedOperationException("Initialization only");
    }
    @Override public int delete(Uri uri, String selection, String[] selectionArgs) {
        throw new UnsupportedOperationException("Initialization only");
    }
    @Override public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
        throw new UnsupportedOperationException("Initialization only");
    }
}
