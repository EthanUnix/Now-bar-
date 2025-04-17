import 'dart:async';
import 'package:flutter/material.dart';
import '../models/now_bar_activity.dart';
import '../services/platform_channel_service.dart';

class SystemInfoService {
  final PlatformChannelService _platformService = PlatformChannelService();
  Timer? _batteryTimer;
  Timer? _mediaTimer;
  
  // Streams for real-time updates
  final _batteryInfoController = StreamController<NowBarActivity>.broadcast();
  final _mediaInfoController = StreamController<NowBarActivity>.broadcast();
  
  Stream<NowBarActivity> get batteryStream => _batteryInfoController.stream;
  Stream<NowBarActivity> get mediaStream => _mediaInfoController.stream;
  
  void initialize() {
    // Start monitoring battery
    _startBatteryMonitoring();
    
    // Start monitoring media
    _startMediaMonitoring();
    
    // Listen to platform battery stream if available
    _platformService.batteryInfoStream().listen((batteryInfo) {
      _processBatteryInfo(batteryInfo);
    });
  }
  
  void dispose() {
    _batteryTimer?.cancel();
    _mediaTimer?.cancel();
    _batteryInfoController.close();
    _mediaInfoController.close();
  }
  
  void _startBatteryMonitoring() {
    // Initial fetch
    _fetchBatteryInfo();
    
    // Set up periodic updates
    _batteryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchBatteryInfo();
    });
  }
  
  void _startMediaMonitoring() {
    // Initial fetch
    _fetchMediaInfo();
    
    // Set up periodic updates
    _mediaTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchMediaInfo();
    });
  }
  
  Future<void> _fetchBatteryInfo() async {
    try {
      final batteryInfo = await _platformService.getBatteryInfo();
      _processBatteryInfo(batteryInfo);
    } catch (e) {
      debugPrint('Error fetching battery info: $e');
    }
  }
  
  void _processBatteryInfo(Map<String, dynamic> batteryInfo) {
    final level = batteryInfo['level'] as int? ?? 0;
    final isCharging = batteryInfo['isCharging'] as bool? ?? false;
    final chargingMethod = batteryInfo['chargingMethod'] as String? ?? 'Unknown';
    final minutesRemaining = batteryInfo['minutesRemaining'] as int? ?? 0;
    
    if (isCharging) {
      final activity = NowBarActivity.charging(
        batteryLevel: level,
        chargingSpeed: chargingMethod,
        timeRemaining: Duration(minutes: minutesRemaining),
      );
      _batteryInfoController.add(activity);
    }
  }
  
  Future<void> _fetchMediaInfo() async {
    try {
      final mediaInfo = await _platformService.getMediaInfo();
      _processMediaInfo(mediaInfo);
    } catch (e) {
      debugPrint('Error fetching media info: $e');
    }
  }
  
  void _processMediaInfo(Map<String, dynamic> mediaInfo) {
    final isPlaying = mediaInfo['isPlaying'] as bool? ?? false;
    final title = mediaInfo['title'] as String? ?? 'Unknown';
    final artist = mediaInfo['artist'] as String? ?? 'Unknown';
    
    if (isPlaying) {
      final activity = NowBarActivity.music(
        title: title,
        artist: artist,
        isPlaying: true,
      );
      _mediaInfoController.add(activity);
    }
  }
  
  Future<bool> controlMedia(String action) async {
    return await _platformService.controlMedia(action);
  }
}
