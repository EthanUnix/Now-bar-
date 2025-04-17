import 'package:flutter/material.dart';
import '../models/now_bar_activity.dart';

class NowBarWidget extends StatelessWidget {
  final NowBarActivity activity;
  final VoidCallback onTap;
  
  const NowBarWidget({
    super.key,
    required this.activity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: _buildContent(),
      ),
    );
  }
  
  Widget _buildContent() {
    switch (activity.type) {
      case ActivityType.music:
        return _buildMusicContent();
      case ActivityType.timer:
        return _buildTimerContent();
      case ActivityType.charging:
        return _buildChargingContent();
      case ActivityType.navigation:
        return _buildNavigationContent();
    }
  }
  
  Widget _buildMusicContent() {
    final isPlaying = activity.data['isPlaying'] as bool? ?? true;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.music_note,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                activity.subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
  
  Widget _buildTimerContent() {
    final isRunning = activity.data['isRunning'] as bool? ?? true;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.timer,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                activity.subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          isRunning ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.stop,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
  
  Widget _buildChargingContent() {
    final batteryLevel = activity.data['batteryLevel'] as int? ?? 50;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.battery_charging_full,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 4,
                    child: Stack(
                      children: [
                        Container(
                          height: 4,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Container(
                          height: 4,
                          width: batteryLevel.toDouble(),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activity.subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            }
          ),
        ),
      ],
    );
  }
  
  Widget _buildNavigationContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.navigation,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                activity.subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.close,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
