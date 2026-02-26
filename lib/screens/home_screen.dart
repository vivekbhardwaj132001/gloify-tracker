import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tracker_app/providers/location_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  void _startTracking() {
    final service = ref.read(backgroundServiceProvider);
    service.startService();
    ref.read(trackingStateProvider.notifier).state = true;
  }

  void _stopTracking() {
    final service = ref.read(backgroundServiceProvider);
    service.invoke('stopService');
    ref.read(trackingStateProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final isTracking = ref.watch(trackingStateProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Gloify Tracker', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1E2C),
              Color(0xFF232526),
              Color(0xFF414345),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glassmorphism-style Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.8, end: 1.0),
                          duration: const Duration(seconds: 2),
                          curve: isTracking ? Curves.elasticOut : Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Icon(
                                isTracking ? Icons.radar : Icons.location_off_rounded,
                                size: 120,
                                color: isTracking ? const Color(0xFF00FF87) : Colors.white38,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'SYSTEM STATUS',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            letterSpacing: 3,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            isTracking ? 'TRACKING ACTIVE' : 'SYSTEM IDLE',
                            key: ValueKey(isTracking),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: isTracking ? const Color(0xFF00FF87) : Colors.white,
                              shadows: isTracking ? [
                                BoxShadow(
                                  color: const Color(0xFF00FF87).withOpacity(0.5),
                                  blurRadius: 10,
                                )
                              ] : [],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Action Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: isTracking
                          ? const LinearGradient(colors: [Color(0xFFFF3B30), Color(0xFFFF453A)])
                          : const LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0072FF)]),
                      boxShadow: [
                        BoxShadow(
                          color: (isTracking ? const Color(0xFFFF3B30) : const Color(0xFF0072FF)).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isTracking ? _stopTracking : _startTracking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isTracking ? 'TERMINATE TRACKING' : 'INITIATE TRACKING',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
