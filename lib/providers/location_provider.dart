import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_app/repositories/location_repository.dart';
import 'package:tracker_app/models/location_data.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  throw UnimplementedError('Initialize this in main');
});

final locationStreamProvider = StreamProvider<void>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.watchLocations();
});

final historyLogsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(locationStreamProvider);
  final repository = ref.read(locationRepositoryProvider);
  return repository.getHistoryLogs();
});

final routePointsProvider = FutureProvider.family<List<LocationData>, int>((ref, sessionId) async {
  ref.watch(locationStreamProvider);
  final repository = ref.read(locationRepositoryProvider);
  return repository.getRoutePoints(sessionId);
});

final trackingStateProvider = StateProvider<bool>((ref) => false);

final backgroundServiceProvider = Provider<FlutterBackgroundService>((ref) {
  return FlutterBackgroundService();
});
