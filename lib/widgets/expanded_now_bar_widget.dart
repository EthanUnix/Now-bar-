import 'package:flutter/material.dart';
import '../models/now_bar_activity.dart';

class ExpandedNowBarWidget extends StatelessWidget {
  final NowBarActivity activity;
  
  const ExpandedNowBarWidget({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          _buildExpandedContent(),
        ],
      ),
    );
  }
  
  Widget _buildExpandedContent() {
    switch (activity.type) {
      case ActivityType.music:
        return _buildExpandedMusicContent();
      case ActivityType.timer:
        return _buildExpandedTimerContent();
      case ActivityType.charging:
        return _buildExpandedChargingContent();
      case ActivityType.navigation:
        return _buildExpandedNavigationContent();
    }
  }
  
  Widget _buildExpandedMusicContent() {
    final isPlaying = activity.data['isPlaying'] as bool? ?? true;
    
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.music_note,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, 
                color: Colors.white, 
                size: 48
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.speaker, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Phone Speaker',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
          ],
        ),
      ],
    );
  }
  
  Widget _buildExpandedTimerContent() {
    final isRunning = activity.data['isRunning'] as bool? ?? true;
    
    return Column(
      children: [
        const Icon(
          Icons.timer,
          color: Colors.orange,
          size: 60,
        ),
        const SizedBox(height: 20),
        Text(
          activity.subtitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
              label: Text(isRunning ? 'Pause' : 'Resume'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildExpandedChargingContent() {
    final batteryLevel = activity.data['batteryLevel'] as int? ?? 50;
    final chargingSpeed = activity.data['chargingSpeed'] as String? ?? 'Fast charging';
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: batteryLevel / 100,
                strokeWidth: 10,
                backgroundColor: Colors.white.withOpacity(0.2),
                color: Colors.green,
              ),
            ),
            Column(
              children: [
                const Icon(
                  Icons.battery_charging_full,
                  color: Colors.green,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  '$batteryLevel%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          chargingSpeed,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          activity.subtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.white70, size: 16),
            SizedBox(width: 8),
            Text(
              'Optimized charging enabled',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildExpandedNavigationContent() {
    final eta = activity.data['eta'] as String? ?? '10:30 AM';
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.blue.shade800,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.map,
              color: Colors.white,
              size: 60,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          activity.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.access_time,
              color: Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'ETA: $eta',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.navigation,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Directions',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'End',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
