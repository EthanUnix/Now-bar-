import 'package:flutter/material.dart';
import '../models/now_bar_activity.dart';
import '../widgets/now_bar_widget.dart';
import '../widgets/expanded_now_bar_widget.dart';

class NowBarController extends ChangeNotifier {
  NowBarActivity? _currentActivity;
  List<NowBarActivity> _activities = [];
  
  NowBarActivity? get currentActivity => _currentActivity;
  List<NowBarActivity> get activities => List.unmodifiable(_activities);
  bool get hasActivities => _activities.isNotEmpty;
  
  void addActivity(NowBarActivity activity) {
    if (!_activities.any((a) => a.type == activity.type)) {
      _activities.add(activity);
      if (_currentActivity == null) {
        _currentActivity = activity;
      }
      notifyListeners();
    } else {
      // Replace existing activity of the same type
      final index = _activities.indexWhere((a) => a.type == activity.type);
      _activities[index] = activity;
      
      if (_currentActivity?.type == activity.type) {
        _currentActivity = activity;
      }
      
      notifyListeners();
    }
  }
  
  void removeActivity(ActivityType type) {
    final wasRemoved = _activities.removeWhere((a) => a.type == type) > 0;
    
    if (wasRemoved) {
      if (_currentActivity?.type == type) {
        _currentActivity = _activities.isNotEmpty ? _activities.first : null;
      }
      
      notifyListeners();
    }
  }
  
  void cycleToNextActivity() {
    if (_activities.length <= 1) return;
    
    final currentIndex = _currentActivity != null 
        ? _activities.indexOf(_currentActivity!) 
        : -1;
    
    if (currentIndex >= 0) {
      final nextIndex = (currentIndex + 1) % _activities.length;
      _currentActivity = _activities[nextIndex];
      notifyListeners();
    }
  }
  
  void cycleToPreviousActivity() {
    if (_activities.length <= 1) return;
    
    final currentIndex = _currentActivity != null 
        ? _activities.indexOf(_currentActivity!) 
        : -1;
    
    if (currentIndex >= 0) {
      final previousIndex = (currentIndex - 1 + _activities.length) % _activities.length;
      _currentActivity = _activities[previousIndex];
      notifyListeners();
    }
  }
  
  void clearAllActivities() {
    _activities.clear();
    _currentActivity = null;
    notifyListeners();
  }
}

class NowBarControllerProvider extends InheritedNotifier<NowBarController> {
  const NowBarControllerProvider({
    super.key,
    required NowBarController controller,
    required super.child,
  }) : super(notifier: controller);
  
  static NowBarController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<NowBarControllerProvider>();
    if (provider == null) {
      throw Exception('No NowBarControllerProvider found in context');
    }
    return provider.notifier!;
  }
}

class NowBarDisplay extends StatelessWidget {
  const NowBarDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = NowBarControllerProvider.of(context);
    
    if (!controller.hasActivities) {
      return const SizedBox.shrink();
    }
    
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dy < 0) {
          // Swipe up
          controller.cycleToNextActivity();
        } else if (details.velocity.pixelsPerSecond.dy > 0) {
          // Swipe down
          controller.cycleToPreviousActivity();
        }
      },
      child: NowBarWidget(
        activity: controller.currentActivity!,
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => ExpandedNowBarWidget(
              activity: controller.currentActivity!,
            ),
          );
        },
      ),
    );
  }
}
