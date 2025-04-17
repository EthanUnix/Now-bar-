package com.example.nowbar.samsung_now_bar;

import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ServiceMethodChannel {
    private static final String CHANNEL = "com.example.nowbar/service";
    private final MainActivity activity;

    public ServiceMethodChannel(MainActivity activity) {
        this.activity = activity;
    }

    public void configureChannel(FlutterEngine flutterEngine) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {
                                case "startService":
                                    result.success(startService());
                                    break;
                                case "stopService":
                                    result.success(stopService());
                                    break;
                                case "isServiceRunning":
                                    result.success(isServiceRunning());
                                    break;
                                case "requestPermissions":
                                    requestPermissions();
                                    result.success(true);
                                    break;
                                default:
                                    result.notImplemented();
                                    break;
                            }
                        }
                );
    }

    private boolean startService() {
        Intent serviceIntent = new Intent(activity, NowBarService.class);
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            activity.startForegroundService(serviceIntent);
        } else {
            activity.startService(serviceIntent);
        }
        
        return true;
    }

    private boolean stopService() {
        Intent serviceIntent = new Intent(activity, NowBarService.class);
        return activity.stopService(serviceIntent);
    }

    private boolean isServiceRunning() {
        ActivityManager manager = (ActivityManager) activity.getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
            if (NowBarService.class.getName().equals(service.service.getClassName())) {
                return true;
            }
        }
        return false;
    }

    private void requestPermissions() {
        // Request overlay permission if needed
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(activity)) {
            Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:" + activity.getPackageName()));
            activity.startActivityForResult(intent, 0);
        }
    }
}
