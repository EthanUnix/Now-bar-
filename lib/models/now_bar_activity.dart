enum ActivityType {
  music,
  timer,
  charging,
  navigation,
}

class NowBarActivity {
  final ActivityType type;
  final String title;
  final String subtitle;
  final Map<String, dynamic> data;
  
  NowBarActivity({
    required this.type,
    required this.title,
    required this.subtitle,
    this.data = const {},
  });
  
  // Factory methods for creating different activity types
  
  factory NowBarActivity.music({
    required String title,
    required String artist,
    String? albumArt,
    bool isPlaying = true,
  }) {
    return NowBarActivity(
      type: ActivityType.music,
      title: title,
      subtitle: artist,
      data: {
        'albumArt': albumArt,
        'isPlaying': isPlaying,
      },
    );
  }
  
  factory NowBarActivity.timer({
    required Duration remaining,
    required bool isRunning,
  }) {
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    final formattedTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    return NowBarActivity(
      type: ActivityType.timer,
      title: 'Timer',
      subtitle: formattedTime,
      data: {
        'remaining': remaining.inSeconds,
        'isRunning': isRunning,
      },
    );
  }
  
  factory NowBarActivity.charging({
    required int batteryLevel,
    required String chargingSpeed,
    required Duration timeRemaining,
  }) {
    final hours = timeRemaining.inHours;
    final minutes = timeRemaining.inMinutes % 60;
    final timeString = hours > 0 
        ? '${hours}h ${minutes}m until full'
        : '${minutes}m until full';
    
    return NowBarActivity(
      type: ActivityType.charging,
      title: '$batteryLevel% • $chargingSpeed',
      subtitle: timeString,
      data: {
        'batteryLevel': batteryLevel,
        'chargingSpeed': chargingSpeed,
        'timeRemaining': timeRemaining.inMinutes,
      },
    );
  }
  
  factory NowBarActivity.navigation({
    required String destination,
    required String nextDirection,
    required String distance,
    required String eta,
  }) {
    return NowBarActivity(
      type: ActivityType.navigation,
      title: destination,
      subtitle: '$nextDirection in $distance',
      data: {
        'nextDirection': nextDirection,
        'distance': distance,
        'eta': eta,
      },
    );
  }
}
