import 'dart:async';
import 'package:flutter/services.dart';

class BackgroundServiceManager {
  static const MethodChannel _channel = MethodChannel('com.example.nowbar/service');
  
  // Start the background service
  Future<bool> startBackgroundService() async {
    try {
      final bool result = await _channel.invokeMethod('startService');
      return result;
    } on PlatformException catch (e) {
      print('Failed to start background service: ${e.message}');
      return false;
    }
  }
  
  // Stop the background service
  Future<bool> stopBackgroundService() async {
    try {
      final bool result = await _channel.invokeMethod('stopService');
      return result;
    } on PlatformException catch (e) {
      print('Failed to stop background service: ${e.message}');
      return false;
    }
  }
  
  // Check if the background service is running
  Future<bool> isServiceRunning() async {
    try {
      final bool result = await _channel.invokeMethod('isServiceRunning');
      return result;
    } on PlatformException catch (e) {
      print('Failed to check service status: ${e.message}');
      return false;
    }
  }
  
  // Request necessary permissions for the service
  Future<bool> requestPermissions() async {
    try {
      final bool result = await _channel.invokeMethod('requestPermissions');
      return result;
    } on PlatformException catch (e) {
      print('Failed to request permissions: ${e.message}');
      return false;
    }
  }
}
