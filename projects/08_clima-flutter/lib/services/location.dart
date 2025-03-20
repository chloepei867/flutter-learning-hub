import 'package:geolocator/geolocator.dart';
final LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 100,
);

class Location {
  late double latitude;
  late double longitude;

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
      latitude = position.latitude;
      longitude = position.longitude;
    } catch(e) {
      print(e);
    }
  }
}

