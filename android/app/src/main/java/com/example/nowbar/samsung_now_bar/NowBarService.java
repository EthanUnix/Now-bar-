package com.example.nowbar.samsung_now_bar;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.PixelFormat;
import android.media.AudioManager;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import java.util.Timer;
import java.util.TimerTask;

public class NowBarService extends Service {
    private static final String CHANNEL_ID = "NowBarServiceChannel";
    private static final int NOTIFICATION_ID = 1;
    
    private WindowManager windowManager;
    private View nowBarView;
    private Timer updateTimer;
    private boolean isLockScreenWidgetShown = false;
    
    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();
    }
    
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // Start as a foreground service with a persistent notification
        startForeground(NOTIFICATION_ID, createNotification());
        
        // Initialize the window manager for overlay
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
        
        // Start monitoring system information
        startMonitoring();
        
        // Return sticky to ensure the service restarts if killed
        return START_STICKY;
    }
    
    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "Now Bar Service Channel",
                    NotificationManager.IMPORTANCE_LOW
            );
            serviceChannel.setShowBadge(false);
            
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(serviceChannel);
        }
    }
    
    private Notification createNotification() {
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(
                this,
                0,
                notificationIntent,
                PendingIntent.FLAG_IMMUTABLE
        );
        
        return new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Now Bar Active")
                .setContentText("Monitoring system activities")
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentIntent(pendingIntent)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .build();
    }
    
    private void startMonitoring() {
        if (updateTimer != null) {
            updateTimer.cancel();
        }
        
        updateTimer = new Timer();
        updateTimer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                new Handler(Looper.getMainLooper()).post(() -> {
                    updateNowBar();
                });
            }
        }, 0, 5000); // Update every 5 seconds
    }
    
    private void updateNowBar() {
        // Check if we should show the Now Bar (e.g., if there's active media or charging)
        boolean shouldShowNowBar = shouldShowNowBar();
        
        if (shouldShowNowBar) {
            if (!isLockScreenWidgetShown) {
                showLockScreenWidget();
            } else {
                updateLockScreenWidget();
            }
        } else {
            if (isLockScreenWidgetShown) {
                hideLockScreenWidget();
            }
        }
    }
    
    private boolean shouldShowNowBar() {
        // Check if there's active media
        AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
        boolean isPlayingMedia = audioManager.isMusicActive();
        
        // Check if device is charging
        IntentFilter ifilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
        Intent batteryStatus = registerReceiver(null, ifilter);
        int status = batteryStatus.getIntExtra(BatteryManager.EXTRA_STATUS, -1);
        boolean isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                            status == BatteryManager.BATTERY_STATUS_FULL;
        
        // For this example, show if either media is playing or device is charging
        return isPlayingMedia || isCharging;
    }
    
    private void showLockScreenWidget() {
        // This is a simplified implementation
        // In a real app, you would need to handle different Android versions and permissions
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // For Android 8.0+, we need SYSTEM_ALERT_WINDOW permission
            // This is just a fallback to notification for demo purposes
            if (!Settings.canDrawOverlays(this)) {
                // Update the notification instead
                updateNotificationWithNowBarInfo();
                return;
            }
        }
        
        // Create the Now Bar view
        LayoutInflater inflater = (LayoutInflater) getSystemService(LAYOUT_INFLATER_SERVICE);
        nowBarView = inflater.inflate(R.layout.now_bar_widget, null);
        
        // Configure the layout parameters for the overlay
        WindowManager.LayoutParams params = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                        ? WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                        : WindowManager.LayoutParams.TYPE_SYSTEM_ALERT,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                        | WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED,
                PixelFormat.TRANSLUCENT
        );
        
        // Position at the bottom center
        params.gravity = Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL;
        params.y = 100; // 100px from bottom
        
        // Add the view to the window
        try {
            windowManager.addView(nowBarView, params);
            isLockScreenWidgetShown = true;
            
            // Update the widget with current information
            updateLockScreenWidget();
        } catch (Exception e) {
            e.printStackTrace();
            // Fallback to notification
            updateNotificationWithNowBarInfo();
        }
    }
    
    private void updateLockScreenWidget() {
        if (nowBarView == null) return;
        
        // Get current information
        AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
        boolean isPlayingMedia = audioManager.isMusicActive();
        
        IntentFilter ifilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
        Intent batteryStatus = registerReceiver(null, ifilter);
        int level = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
        int scale = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        float batteryPct = level * 100 / (float)scale;
        
        int status = batteryStatus.getIntExtra(BatteryManager.EXTRA_STATUS, -1);
        boolean isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                            status == BatteryManager.BATTERY_STATUS_FULL;
        
        // Update the view based on what's active
        TextView titleText = nowBarView.findViewById(R.id.now_bar_title);
        TextView subtitleText = nowBarView.findViewById(R.id.now_bar_subtitle);
        
        if (isPlayingMedia) {
            // Show media information (simplified)
            titleText.setText("Now Playing");
            subtitleText.setText("Unknown Track");
        } else if (isCharging) {
            // Show charging information
            titleText.setText("Charging: " + (int)batteryPct + "%");
            subtitleText.setText("Battery charging");
        }
    }
    
    private void hideLockScreenWidget() {
        if (nowBarView != null) {
            try {
                windowManager.removeView(nowBarView);
                nowBarView = null;
                isLockScreenWidgetShown = false;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    private void updateNotificationWithNowBarInfo() {
        // Fallback method when overlay isn't possible
        // Update the notification with Now Bar information
        
        NotificationManager notificationManager = getSystemService(NotificationManager.class);
        
        // Get current information (simplified)
        AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
        boolean isPlayingMedia = audioManager.isMusicActive();
        
        IntentFilter ifilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
        Intent batteryStatus = registerReceiver(null, ifilter);
        int level = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
        int scale = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        float batteryPct = level * 100 / (float)scale;
        
        int status = batteryStatus.getIntExtra(BatteryManager.EXTRA_STATUS, -1);
        boolean isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                            status == BatteryManager.BATTERY_STATUS_FULL;
        
        // Create content based on what's active
        String title = "Now Bar Active";
        String content = "Monitoring system activities";
        
        if (isPlayingMedia) {
            title = "Now Playing";
            content = "Unknown Track";
        } else if (isCharging) {
            title = "Charging: " + (int)batteryPct + "%";
            content = "Battery charging";
        }
        
        // Update the notification
        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle(title)
                .setContentText(content)
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .build();
        
        notificationManager.notify(NOTIFICATION_ID, notification);
    }
    
    @Override
    public void onDestroy() {
        if (updateTimer != null) {
            updateTimer.cancel();
            updateTimer = null;
        }
        
        hideLockScreenWidget();
        super.onDestroy();
    }
    
    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
