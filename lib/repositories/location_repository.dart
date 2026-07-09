import 'package:geolocator/geolocator.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';

/// Repository for device location retrieval and reverse geocoding.
class LocationRepository {
  final LocationService _locationService = LocationService();
  final GeocodingService _geocodingService = GeocodingService();

  /// Gets current device GPS position.
  Future<Position> getCurrentLocation() =>
      _locationService.getCurrentLocation();

  /// Checks if device GPS location services are enabled.
  Future<bool> isGpsEnabled() => _locationService.isGpsEnabled();

  /// Performs reverse-geocoding of coordinates into a [GeocodedAddress].
  Future<GeocodedAddress> reverseGeocode(double lat, double lng) {
    return _geocodingService.reverseGeocode(lat, lng);
  }
}
