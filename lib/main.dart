import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_app/repositories/location_repository.dart';
import 'package:tracker_app/providers/location_provider.dart';
import 'package:tracker_app/services/background_service.dart';
import 'package:tracker_app/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final locationRepository = LocationRepository();
  await locationRepository.init();
  
  await initializeService();

  runApp(
    ProviderScope(
      overrides: [
        locationRepositoryProvider.overrideWithValue(locationRepository),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      title: 'Gloify Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
