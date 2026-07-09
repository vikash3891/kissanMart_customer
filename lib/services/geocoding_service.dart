import 'package:geocoding/geocoding.dart';

/// Structured address parsed from raw geocoding Placemark data.
class GeocodedAddress {
  final String houseNo;
  final String area;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final String? landmark;
  final List<String> nearbyLandmarks;

  GeocodedAddress({
    required this.houseNo,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    this.landmark,
    required this.nearbyLandmarks,
  });

  String get formattedAddress {
    final parts = [
      if (houseNo.isNotEmpty) houseNo,
      if (area.isNotEmpty) area,
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (pincode.isNotEmpty) pincode,
    ];
    return parts.join(', ');
  }
}

/// Service responsible for geocoding and reverse-geocoding coordinates.
class GeocodingService {
  final Geocoding _geocoding = Geocoding();

  /// Reverse geocodes the given coordinates to a [GeocodedAddress].
  Future<GeocodedAddress> reverseGeocode(
      double latitude, double longitude) async {
    try {
      final placemarks = await _geocoding
          .placemarkFromCoordinates(latitude, longitude)
          .timeout(const Duration(milliseconds: 1500));
      if (placemarks.isEmpty) {
        throw Exception('No address found for these coordinates.');
      }

      final pm = placemarks.first;

      final houseNo = pm.name ?? pm.subThoroughfare ?? '';

      final streetPart = pm.thoroughfare ?? '';
      final subLocalityPart = pm.subLocality ?? '';
      final area = [
        if (streetPart.isNotEmpty) streetPart,
        if (subLocalityPart.isNotEmpty) subLocalityPart,
      ].join(', ');

      final city = pm.locality ?? pm.subAdministrativeArea ?? '';
      final state = pm.administrativeArea ?? '';
      final pincode = pm.postalCode ?? '';
      final country = pm.country ?? '';

      String? landmark;
      final nearby = <String>[];

      final searchArea =
          '${pm.name} ${pm.thoroughfare} ${pm.subLocality}'.toLowerCase();
      if (searchArea.contains('school') || searchArea.contains('college')) {
        nearby.add('Local School / Institute');
        landmark = pm.name;
      }
      if (searchArea.contains('hospital') ||
          searchArea.contains('clinic') ||
          searchArea.contains('med')) {
        nearby.add('Healthcare Center / Hospital');
        landmark = pm.name;
      }
      if (searchArea.contains('mall') ||
          searchArea.contains('market') ||
          searchArea.contains('store')) {
        nearby.add('Local Market / Mall');
        landmark = pm.name;
      }
      if (searchArea.contains('station') ||
          searchArea.contains('metro') ||
          searchArea.contains('bus')) {
        nearby.add('Metro / Railway Station');
        landmark = pm.name;
      }

      if (nearby.isEmpty) {
        nearby.addAll([
          'Nearby Public Park',
          'Local Grocery Market',
          'Community Center',
        ]);
      }

      return GeocodedAddress(
        houseNo: houseNo,
        area: area.isNotEmpty ? area : 'Unknown Area',
        city: city.isNotEmpty ? city : 'Unknown City',
        state: state.isNotEmpty ? state : 'Unknown State',
        pincode: pincode.isNotEmpty ? pincode : '000000',
        country: country,
        landmark: landmark,
        nearbyLandmarks: nearby,
      );
    } catch (e) {
      throw Exception('Reverse geocoding failed: $e');
    }
  }
}
