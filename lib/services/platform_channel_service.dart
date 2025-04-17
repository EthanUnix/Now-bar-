import 'dart:async';
import 'package:flutter/services.dart';

class PlatformChannelService {
  static const MethodChannel _batteryChannel = MethodChannel('com.example.nowbar/battery');
  static const EventChannel _batteryEventChannel = EventChannel('com.example.nowbar/battery/stream');
  static const MethodChannel _mediaChannel = MethodChannel('com.example.nowbar/media');
  static const MethodChannel _systemChannel = MethodChannel('com.example.nowbar/system');
  
  // Battery information
  Future<Map<String, dynamic>> getBatteryInfo() async {
    try {
      final Map<dynamic, dynamic> result = await _batteryChannel.invokeMethod('getBatteryInfo');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print('Failed to get battery info: ${e.message}');
      return {
        'level': 0,
        'isCharging': false,
        'chargingMethod': 'Unknown',
        'minutesRemaining': 0,
      };
    }
  }
  
  Stream<Map<String, dynamic>> batteryInfoStream() {
    return _batteryEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => Map<String, dynamic>.from(event));
  }
  
  // Media information and controls
  Future<Map<String, dynamic>> getMediaInfo() async {
    try {
      final Map<dynamic, dynamic> result = await _mediaChannel.invokeMethod('getMediaInfo');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print('Failed to get media info: ${e.message}');
      return {
        'isPlaying': false,
        'title': 'Unknown',
        'artist': 'Unknown',
        'albumArt': null,
      };
    }
  }
  
  Future<bool> controlMedia(String action) async {
    try {
      final bool result = await _mediaChannel.invokeMethod('controlMedia', {'action': action});
      return result;
    } on PlatformException catch (e) {
      print('Failed to control media: ${e.message}');
      return false;
    }
  }
  
  // System information
  Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      final Map<dynamic, dynamic> result = await _systemChannel.invokeMethod('getSystemInfo');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print('Failed to get system info: ${e.message}');
      return {
        'deviceModel': 'Unknown',
        'androidVersion': 'Unknown',
        'sdkVersion': 0,
      };
    }
  }
}
