package com.example.nowbar.samsung_now_bar;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String BATTERY_CHANNEL = "com.example.nowbar/battery";
    private static final String MEDIA_CHANNEL = "com.example.nowbar/media";
    private static final String SYSTEM_CHANNEL = "com.example.nowbar/system";
    
    private EventChannel batteryEventChannel;
    private EventChannel.EventSink batteryEventSink;
    private Timer batteryTimer;
    
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        
        // Setup method channels
        setupBatteryChannel(flutterEngine);
        setupMediaChannel(flutterEngine);
        setupSystemChannel(flutterEngine);
    }
    
    private void setupBatteryChannel(FlutterEngine flutterEngine) {
        // Method channel for one-time battery info requests
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), BATTERY_CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("getBatteryInfo")) {
                        Map<String, Object> batteryInfo = getBatteryInfo();
                        result.success(batteryInfo);
                    } else {
                        result.notImplemented();
                    }
                }
            );
        
        // Event channel for continuous battery updates
        batteryEventChannel = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), 
                                              BATTERY_CHANNEL + "/stream");
        batteryEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                batteryEventSink = events;
                startBatteryMonitoring();
            }

            @Override
            public void onCancel(Object arguments) {
                batteryEventSink = null;
                stopBatteryMonitoring();
            }
        });
    }
    
    private void setupMediaChannel(FlutterEngine flutterEngine) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), MEDIA_CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("getMediaInfo")) {
                        Map<String, Object> mediaInfo = getMediaInfo();
                        result.success(mediaInfo);
                    } else if (call.method.equals("controlMedia")) {
                        String action = call.argument("action");
                        boolean success = controlMedia(action);
                        result.success(success);
                    } else {
                        result.notImplemented();
                    }
                }
            );
    }
    
    private void setupSystemChannel(FlutterEngine flutterEngine) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), SYSTEM_CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("getSystemInfo")) {
                        Map<String, Object> systemInfo = getSystemInfo();
                        result.success(systemInfo);
                    } else {
                        result.notImplemented();
                    }
                }
            );
    }
    
    private Map<String, Object> getBatteryInfo() {
        IntentFilter ifilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
        Intent batteryStatus = getContext().registerReceiver(null, ifilter);
        
        int level = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
        int scale = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        float batteryPct = level * 100 / (float)scale;
        
        int status = batteryStatus.getIntExtra(BatteryManager.EXTRA_STATUS, -1);
        boolean isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                            status == BatteryManager.BATTERY_STATUS_FULL;
        
        int chargePlug = batteryStatus.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1);
        boolean usbCharge = chargePlug == BatteryManager.BATTERY_PLUGGED_USB;
        boolean acCharge = chargePlug == BatteryManager.BATTERY_PLUGGED_AC;
        
        String chargingMethod = "Not charging";
        if (isCharging) {
            if (usbCharge) {
                chargingMethod = "USB";
            } else if (acCharge) {
                chargingMethod = "AC";
            } else {
                chargingMethod = "Wireless";
            }
        }
        
        // Estimate time remaining (this is a simplified example)
        // In a real app, you would need to track battery level changes over time
        int estimatedMinutesRemaining = isCharging ? 
            (int)((100 - batteryPct) * 1.5) : // Rough estimate for charging
            (int)(batteryPct * 5);            // Rough estimate for discharging
        
        Map<String, Object> result = new HashMap<>();
        result.put("level", (int)batteryPct);
        result.put("isCharging", isCharging);
        result.put("chargingMethod", chargingMethod);
        result.put("minutesRemaining", estimatedMinutesRemaining);
        
        return result;
    }
    
    private void startBatteryMonitoring() {
        if (batteryTimer != null) {
            batteryTimer.cancel();
        }
        
        batteryTimer = new Timer();
        batteryTimer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                if (batteryEventSink != null) {
                    new Handler(Looper.getMainLooper()).post(() -> {
                        batteryEventSink.success(getBatteryInfo());
                    });
                }
            }
        }, 0, 30000); // Update every 30 seconds
    }
    
    private void stopBatteryMonitoring() {
        if (batteryTimer != null) {
            batteryTimer.cancel();
            batteryTimer = null;
        }
    }
    
    private Map<String, Object> getMediaInfo() {
        AudioManager audioManager = (AudioManager) getContext().getSystemService(Context.AUDIO_SERVICE);
        boolean isPlaying = audioManager.isMusicActive();
        
        // Note: Getting actual media metadata requires using MediaSession APIs
        // This is a simplified example
        Map<String, Object> result = new HashMap<>();
        result.put("isPlaying", isPlaying);
        result.put("title", "Unknown Title");
        result.put("artist", "Unknown Artist");
        result.put("albumArt", null);
        
        return result;
    }
    
    private boolean controlMedia(String action) {
        AudioManager audioManager = (AudioManager) getContext().getSystemService(Context.AUDIO_SERVICE);
        
        switch (action) {
            case "play":
                audioManager.dispatchMediaKeyEvent(new android.view.KeyEvent(
                        android.view.KeyEvent.ACTION_DOWN, android.view.KeyEvent.KEYCODE_MEDIA_PLAY));
                return true;
            case "pause":
                audioManager.dispatchMediaKeyEvent(new android.view.KeyEvent(
                        android.view.KeyEvent.ACTION_DOWN, android.view.KeyEvent.KEYCODE_MEDIA_PAUSE));
                return true;
            case "next":
                audioManager.dispatchMediaKeyEvent(new android.view.KeyEvent(
                        android.view.KeyEvent.ACTION_DOWN, android.view.KeyEvent.KEYCODE_MEDIA_NEXT));
                return true;
            case "previous":
                audioManager.dispatchMediaKeyEvent(new android.view.KeyEvent(
                        android.view.KeyEvent.ACTION_DOWN, android.view.KeyEvent.KEYCODE_MEDIA_PREVIOUS));
                return true;
            default:
                return false;
        }
    }
    
    private Map<String, Object> getSystemInfo() {
        Map<String, Object> result = new HashMap<>();
        result.put("deviceModel", Build.MODEL);
        result.put("androidVersion", Build.VERSION.RELEASE);
        result.put("sdkVersion", Build.VERSION.SDK_INT);
        
        return result;
    }
    
    @Override
    public void onDestroy() {
        stopBatteryMonitoring();
        super.onDestroy();
    }
}
