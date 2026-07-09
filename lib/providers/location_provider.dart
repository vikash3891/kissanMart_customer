import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../repositories/location_repository.dart';
import '../repositories/map_repository.dart';
import '../services/geocoding_service.dart';

/// Provider responsible for managing location, GPS, reverse geocoding, and map suggestions.
class LocationProvider extends ChangeNotifier {
  final LocationRepository _locationRepo = LocationRepository();
  final MapRepository _mapRepo = MapRepository();

  bool _loading = false;
  Position? _currentPosition;
  GeocodedAddress? _selectedAddress;
  List<PlacePrediction> _predictions = [];
  String? _error;

  bool get loading => _loading;
  bool get isLoading => _loading; // compatibility
  Position? get currentPosition => _currentPosition;
  GeocodedAddress? get selectedAddress => _selectedAddress;
  List<String> get searchResults =>
      _predictions.map((p) => p.description).toList();
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSearchResults() {
    _predictions = [];
    notifyListeners();
  }

  /// Detects GPS location and automatically reverse geocodes it.
  Future<void> fetchCurrentLocation() async {
    _loading = true;
    _error = null;
    _currentPosition = null;
    _selectedAddress = null;
    notifyListeners();

    try {
      final pos = await _locationRepo.getCurrentLocation();
      _currentPosition = pos;
      final address =
          await _locationRepo.reverseGeocode(pos.latitude, pos.longitude);
      _selectedAddress = address;
      _error = null;
    } catch (e) {
      _currentPosition = null;
      _selectedAddress = null;
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Reverse geocodes specific coordinates (e.g. from map dragging).
  Future<void> reverseGeocodeLocation(double lat, double lng) async {
    try {
      final address = await _locationRepo.reverseGeocode(lat, lng);
      _selectedAddress = address;
      _error = null;
    } catch (e) {
      _selectedAddress = null;
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  /// Queries place suggestions based on query text.
  Future<void> searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      _predictions = [];
      notifyListeners();
      return;
    }

    try {
      _predictions = await _mapRepo.searchPlaces(query);
      _error = null;
    } catch (e) {
      _predictions = [];
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  /// Fetches real coordinates for a chosen prediction string.
  Future<LatLng?> getPlaceCoordinates(String description) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final prediction =
          _predictions.firstWhere((p) => p.description == description);
      final latLng = await _mapRepo.getPlaceDetails(prediction.placeId);
      _error = null;
      return latLng;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
