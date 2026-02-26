import 'package:isar/isar.dart';
import 'package:tracker_app/models/location_data.dart';
import 'package:path_provider/path_provider.dart';

class LocationRepository {
  late Isar _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [LocationDataSchema],
      directory: dir.path,
      inspector: false,
    );
  }

  Future<void> saveLocation(double latitude, double longitude, {int? sessionId}) async {
    final locationData = LocationData(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      sessionId: sessionId ?? DateTime.now().millisecondsSinceEpoch,
    );

    await _isar.writeTxn(() async {
      await _isar.locationDatas.put(locationData);
    });
  }

  Future<List<LocationData>> getRecentLocations({int limit = 10}) async {
    return await _isar.locationDatas
        .where()
        .sortByTimestampDesc()
        .limit(limit)
        .findAll();
  }

  Future<List<LocationData>> getLocationsForToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    return await _isar.locationDatas
        .where()
        .filter()
        .timestampGreaterThan(startOfDay)
        .sortByTimestamp()
        .findAll();
  }
  
  Stream<void> watchLocations() {
    return _isar.locationDatas.watchLazy();
  }

  Future<List<Map<String, dynamic>>> getHistoryLogs() async {
    final allRecords = await _isar.locationDatas.where().sortByTimestampDesc().findAll();
    
    final Map<int, List<LocationData>> grouped = {};
    for (var record in allRecords) {
      grouped.putIfAbsent(record.sessionId, () => []).add(record);
    }
    
    final sessions = grouped.keys.toList();
    sessions.sort((a, b) {
      final aLatest = grouped[a]!.first.timestamp;
      final bLatest = grouped[b]!.first.timestamp;
      return bLatest.compareTo(aLatest);
    });
    
    final recentSessions = sessions.take(10).toList();
    List<Map<String, dynamic>> result = [];
    
    for (var sessionId in recentSessions) {
      final records = grouped[sessionId]!;
      final endRecord = records.first;
      final startRecord = records.last;
      
      result.add({
        'sessionId': sessionId,
        'startTime': startRecord.timestamp,
        'endTime': endRecord.timestamp,
        'startLoc': {'lat': startRecord.latitude, 'lng': startRecord.longitude},
        'endLoc': {'lat': endRecord.latitude, 'lng': endRecord.longitude},
        'pointCount': records.length,
      });
    }
    return result;
  }

  Future<List<LocationData>> getRoutePoints(int sessionId) async {
    return await _isar.locationDatas
        .filter()
        .sessionIdEqualTo(sessionId)
        .sortByTimestamp()
        .findAll();
  }
}
