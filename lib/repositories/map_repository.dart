import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/api_constants.dart';

class PlacePrediction {
  final String description;
  final String placeId;

  PlacePrediction({
    required this.description,
    required this.placeId,
  });
}

/// Repository responsible for map operations, place search autocomplete, etc.
/// Real Google Places API integration.
class MapRepository {
  /// Searches for places/addresses by a query string using real Google Places Autocomplete API.
  Future<List<PlacePrediction>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&key=${ApiConstants.googleMapsApiKey}'
        '&components=country:in';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 'OK') {
          final List predictionsList = decoded['predictions'] as List? ?? [];
          return predictionsList
              .map((e) => PlacePrediction(
                    description: e['description'] ?? '',
                    placeId: e['place_id'] ?? '',
                  ))
              .toList();
        } else if (decoded['status'] == 'REQUEST_DENIED') {
          throw Exception(
              'Google Places API error: Request Denied. Details: ${decoded['error_message'] ?? 'Check key restriction or billing.'}');
        } else if (decoded['status'] == 'ZERO_RESULTS') {
          return [];
        } else {
          throw Exception('Google Places API error: ${decoded['status']}');
        }
      } else {
        throw Exception(
            'Failed to connect to Google Places API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Autocomplete search failed: $e');
    }
  }

  /// Fetches coordinate details for a specific place using Google Places Details API.
  Future<LatLng> getPlaceDetails(String placeId) async {
    final url = 'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=geometry'
        '&key=${ApiConstants.googleMapsApiKey}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 'OK') {
          final location = decoded['result']['geometry']['location'];
          final lat = (location['lat'] as num).toDouble();
          final lng = (location['lng'] as num).toDouble();
          return LatLng(lat, lng);
        } else {
          throw Exception(
              'Google Places Details API error: ${decoded['status']}');
        }
      } else {
        throw Exception(
            'Failed to connect to Google Places Details API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch place coordinates: $e');
    }
  }
}
