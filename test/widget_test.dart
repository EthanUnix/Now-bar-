import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samsung_now_bar/models/now_bar_activity.dart';
import 'package:samsung_now_bar/widgets/now_bar_widget.dart';
import 'package:samsung_now_bar/widgets/expanded_now_bar_widget.dart';

void main() {
  group('Now Bar Widget Tests', () {
    testWidgets('Music activity displays correctly', (WidgetTester tester) async {
      // Create a music activity
      final activity = NowBarActivity.music(
        title: 'Test Song',
        artist: 'Test Artist',
        isPlaying: true,
      );
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NowBarWidget(
                activity: activity,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      
      // Verify the widget displays the correct information
      expect(find.text('Test Song'), findsOneWidget);
      expect(find.text('Test Artist'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });
    
    testWidgets('Timer activity displays correctly', (WidgetTester tester) async {
      // Create a timer activity
      final activity = NowBarActivity.timer(
        remaining: const Duration(minutes: 5, seconds: 30),
        isRunning: true,
      );
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NowBarWidget(
                activity: activity,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      
      // Verify the widget displays the correct information
      expect(find.text('Timer'), findsOneWidget);
      expect(find.text('05:30'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
    });
    
    testWidgets('Charging activity displays correctly', (WidgetTester tester) async {
      // Create a charging activity
      final activity = NowBarActivity.charging(
        batteryLevel: 65,
        chargingSpeed: 'Fast charging',
        timeRemaining: const Duration(minutes: 35),
      );
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NowBarWidget(
                activity: activity,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      
      // Verify the widget displays the correct information
      expect(find.text('65% • Fast charging'), findsOneWidget);
      expect(find.text('35m until full'), findsOneWidget);
    });
    
    testWidgets('Navigation activity displays correctly', (WidgetTester tester) async {
      // Create a navigation activity
      final activity = NowBarActivity.navigation(
        destination: 'Central Park',
        nextDirection: 'Turn right',
        distance: '500 ft',
        eta: '10:30 AM',
      );
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NowBarWidget(
                activity: activity,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      
      // Verify the widget displays the correct information
      expect(find.text('Central Park'), findsOneWidget);
      expect(find.text('Turn right in 500 ft'), findsOneWidget);
    });
  });
  
  group('Expanded Now Bar Widget Tests', () {
    testWidgets('Expanded music view displays correctly', (WidgetTester tester) async {
      // Create a music activity
      final activity = NowBarActivity.music(
        title: 'Test Song',
        artist: 'Test Artist',
        isPlaying: true,
      );
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandedNowBarWidget(
              activity: activity,
            ),
          ),
        ),
      );
      
      // Verify the expanded view displays the correct information
      expect(find.text('Test Song'), findsOneWidget);
      expect(find.text('Test Artist'), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle_filled), findsOneWidget);
      expect(find.byIcon(Icons.skip_previous), findsOneWidget);
      expect(find.byIcon(Icons.skip_next), findsOneWidget);
    });
  });
}
