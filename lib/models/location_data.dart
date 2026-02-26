import 'package:isar/isar.dart';

part 'location_data.g.dart';

@collection
class LocationData {
  Id id = Isar.autoIncrement;

  late double latitude;

  late double longitude;

  late DateTime timestamp;

  late int sessionId;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.sessionId,
  });
}
