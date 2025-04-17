import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controllers/now_bar_controller.dart';
import 'models/now_bar_activity.dart';
import 'services/background_service_manager.dart';
import 'services/system_info_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Samsung Now Bar Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nowBarController = NowBarController();
  final _backgroundServiceManager = BackgroundServiceManager();
  final _systemInfoService = SystemInfoService();
  bool _isServiceRunning = false;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    // Initialize system info service
    _systemInfoService.initialize();
    
    // Listen to battery updates
    _systemInfoService.batteryStream.listen((activity) {
      _nowBarController.addActivity(activity);
    });
    
    // Listen to media updates
    _systemInfoService.mediaStream.listen((activity) {
      _nowBarController.addActivity(activity);
    });
    
    // Check if background service is running
    _isServiceRunning = await _backgroundServiceManager.isServiceRunning();
    setState(() {});
    
    // Request necessary permissions
    await _backgroundServiceManager.requestPermissions();
  }
  
  @override
  void dispose() {
    _systemInfoService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return NowBarControllerProvider(
      controller: _nowBarController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Now Bar Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            Switch(
              value: _isServiceRunning,
              onChanged: (value) async {
                if (value) {
                  await _backgroundServiceManager.startBackgroundService();
                } else {
                  await _backgroundServiceManager.stopBackgroundService();
                }
                
                _isServiceRunning = await _backgroundServiceManager.isServiceRunning();
                setState(() {});
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Mock lock screen area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade900,
                      Colors.black,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Mock lock screen content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '12:34',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 72,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Wednesday, April 16',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Now Bar at the bottom
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 20,
                      child: Center(
                        child: const NowBarDisplay(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Controls for demo
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Demo Controls',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Text('Background Service'),
                          Switch(
                            value: _isServiceRunning,
                            onChanged: (value) async {
                              if (value) {
                                await _backgroundServiceManager.startBackgroundService();
                              } else {
                                await _backgroundServiceManager.stopBackgroundService();
                              }
                              
                              _isServiceRunning = await _backgroundServiceManager.isServiceRunning();
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _nowBarController.addActivity(
                              NowBarActivity.music(
                                title: 'Imagine',
                                artist: 'John Lennon',
                                isPlaying: true,
                              ),
                            );
                          },
                          icon: const Icon(Icons.music_note),
                          label: const Text('Music'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _nowBarController.addActivity(
                              NowBarActivity.timer(
                                remaining: const Duration(minutes: 5, seconds: 30),
                                isRunning: true,
                              ),
                            );
                          },
                          icon: const Icon(Icons.timer),
                          label: const Text('Timer'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _nowBarController.addActivity(
                              NowBarActivity.charging(
                                batteryLevel: 65,
                                chargingSpeed: 'Fast charging',
                                timeRemaining: const Duration(minutes: 35),
                              ),
                            );
                          },
                          icon: const Icon(Icons.battery_charging_full),
                          label: const Text('Charging'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _nowBarController.addActivity(
                              NowBarActivity.navigation(
                                destination: 'Central Park',
                                nextDirection: 'Turn right',
                                distance: '500 ft',
                                eta: '10:30 AM',
                              ),
                            );
                          },
                          icon: const Icon(Icons.navigation),
                          label: const Text('Navigation'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _nowBarController.clearAllActivities();
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear All Activities'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
