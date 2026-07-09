import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service responsible for device GPS location retrieval and permissions.
class LocationService {
  /// Checks if device GPS location service is enabled.
  Future<bool> isGpsEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Requests location permissions.
  Future<PermissionStatus> requestLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isDenied) {
      return await Permission.location.request();
    }
    return status;
  }

  /// Fetches the user's current [Position] if GPS is enabled and permissions are granted.
  Future<Position> getCurrentLocation() async {
    final gpsEnabled = await isGpsEnabled();
    if (!gpsEnabled) {
      throw Exception(
          'GPS is disabled. Please enable location services in your system settings.');
    }

    var permission = await Permission.location.status;
    if (permission.isDenied) {
      permission = await Permission.location.request();
      if (permission.isDenied) {
        throw Exception('Location permissions were denied.');
      }
    }

    if (permission.isPermanentlyDenied) {
      throw Exception(
          'Location permissions are permanently denied. Please enable them in app settings.');
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } on TimeoutException {
      throw Exception(
          'Location detection timed out. Please ensure GPS is active and has a signal, or choose location on the map manually.');
    } catch (e) {
      throw Exception('Could not fetch location: $e');
    }
  }
}
