import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';
import 'package:tracker_app/models/location_data.dart';
import 'package:path_provider/path_provider.dart';


Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,

      initialNotificationTitle: 'TRACKING LOCATION',
      initialNotificationContent: 'GuardianRoute is tracking your location in background',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [LocationDataSchema],
    directory: dir.path,
    inspector: false,
  );

  int currentSessionId = DateTime.now().millisecondsSinceEpoch;

  Future<void> fetchAndSaveLocation() async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: "Tracking Location",
          content: "Updated at ${DateTime.now().toLocal()}",
        );
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final locationData = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        sessionId: currentSessionId,
      );

      await isar.writeTxn(() async {
        await isar.locationDatas.put(locationData);
      });

      print("Location saved: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  // Fetch immediately once
  await fetchAndSaveLocation();

  // Then fetch repeatedly every 5 minutes
  Timer.periodic(const Duration(minutes: 5), (timer) async {
    await fetchAndSaveLocation();
  });
}
