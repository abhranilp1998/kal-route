import 'package:geolocator/geolocator.dart';

/// Current device location via geolocator (GPS on Android, the browser
/// Geolocation API on web). Throws [LocationUnavailable] with a user-facing
/// reason instead of failing silently.
class LocationService {
  const LocationService();

  Future<({double lat, double lng})> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationUnavailable('Location is turned off on this device.');
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied) throw LocationUnavailable('Location permission denied.');
    if (perm == LocationPermission.deniedForever) {
      throw LocationUnavailable('Location permission is blocked. Enable it in system settings.');
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
    );
    return (lat: pos.latitude, lng: pos.longitude);
  }
}

class LocationUnavailable implements Exception {
  LocationUnavailable(this.message);
  final String message;
  @override
  String toString() => message;
}
