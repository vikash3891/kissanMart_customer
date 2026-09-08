import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/location_provider.dart';
import '../../api_models/address.dart';
import 'address_screen.dart';

/// Premium Blinkit-style Location Picker screen using Google Maps.
class LocationPickerScreen extends StatefulWidget {
  final ApiAddress? editItem;

  const LocationPickerScreen({super.key, this.editItem});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  LatLng _currentCenter =
      const LatLng(28.6139, 77.2090); // Default to New Delhi
  bool _isMapDragging = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.fetchCurrentLocation();

    if (locationProvider.error == null &&
        locationProvider.currentPosition != null) {
      final pos = locationProvider.currentPosition!;
      _currentCenter = LatLng(pos.latitude, pos.longitude);
      _animateToLatLng(_currentCenter);
    } else if (locationProvider.error != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locationProvider.error!),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => Geolocator.openAppSettings(),
          ),
        ),
      );
    }
  }

  Future<void> _animateToLatLng(LatLng target) async {
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 16.5),
      ),
    );
  }

  void _onCameraMove(CameraPosition position) {
    _currentCenter = position.target;
    setState(() {
      _isMapDragging = true;
    });
  }

  void _onCameraIdle() {
    setState(() {
      _isMapDragging = false;
    });
    // Reverse geocode the new center
    context.read<LocationProvider>().reverseGeocodeLocation(
          _currentCenter.latitude,
          _currentCenter.longitude,
        );
  }

  void _handleSearch(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      context.read<LocationProvider>().searchPlaces(query);
    });
  }

  void _selectSuggestion(String suggestion) async {
    _searchController.text = suggestion;
    _searchFocusNode.unfocus();
    final locationProvider = context.read<LocationProvider>();
    locationProvider.clearSearchResults();

    final target = await locationProvider.getPlaceCoordinates(suggestion);
    if (target != null) {
      _animateToLatLng(target);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locationProvider.error ??
              'Failed to resolve location coordinates'),
          backgroundColor: context.colors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final colors = context.colors;

    final address = locationProvider.selectedAddress;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Google Map ───────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: 14.5,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _mapController.complete(controller),
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
          ),

          // ── Centered Static Pin ──────────────────────────────────────────
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: AnimatedScale(
                scale: _isMapDragging ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  Icons.location_on,
                  color: colors.danger,
                  size: 48,
                ),
              ),
            ),
          ),

          // ── Search & Autocomplete ────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: _handleSearch,
                          decoration: InputDecoration(
                            hintText: 'Search for area, street, pincode...',
                            prefixIcon: Icon(Icons.search, color: colors.primary),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      locationProvider.clearSearchResults();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                        if (locationProvider.searchResults.isNotEmpty) ...[
                          const Divider(height: 1),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: locationProvider.searchResults.length,
                              itemBuilder: (context, index) {
                                final item =
                                    locationProvider.searchResults[index];
                                return ListTile(
                                  leading:
                                      const Icon(Icons.location_on_outlined),
                                  title: Text(item),
                                  onTap: () => _selectSuggestion(item),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // "Use Current Location" Quick Shortcut
                if (!_searchFocusNode.hasFocus)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: _initLocation,
                        child: Chip(
                          backgroundColor: Colors.white,
                          avatar: Icon(Icons.my_location,
                              color: colors.primary, size: 18),
                          label: Text(
                            'Use Current Location',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: colors.primary),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Bottom Panel (Zepto/Blinkit Style) ───────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Card(
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: colors.primary, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isMapDragging
                                    ? 'Locating...'
                                    : (address != null
                                        ? address.city
                                        : (locationProvider.error != null
                                            ? 'Location Error'
                                            : 'Select Location')),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: locationProvider.error != null &&
                                          address == null
                                      ? Colors.red
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isMapDragging
                                    ? 'Calculating address...'
                                    : (address != null
                                        ? address.formattedAddress
                                        : (locationProvider.error ??
                                            'Drag the map to choose location')),
                                style: TextStyle(
                                  color: locationProvider.error != null &&
                                          address == null
                                      ? Colors.red
                                      : Colors.grey,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (address != null &&
                        address.nearbyLandmarks.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Nearby Landmarks detected:',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 32,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: address.nearbyLandmarks.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Chip(
                                padding: EdgeInsets.zero,
                                labelStyle: const TextStyle(fontSize: 11),
                                label: Text(address.nearbyLandmarks[i]),
                                backgroundColor: Colors.grey[100],
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Confirm Action Button
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primary,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: (_isMapDragging || address == null)
                          ? null
                          : () {
                              final prefill = ApiAddress(
                                id: widget.editItem?.id ?? 0,
                                userId: widget.editItem?.userId ?? 0,
                                fullName: widget.editItem?.fullName ?? '',
                                phone: widget.editItem?.phone ?? '',
                                pincode: address.pincode,
                                state: address.state,
                                city: address.city,
                                houseNo: address.houseNo,
                                area: address.area,
                                landmark: address.landmark,
                                addressType:
                                    widget.editItem?.addressType ?? 'home',
                                isDefault: widget.editItem?.isDefault ?? false,
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddressForm(
                                    item: prefill,
                                    isNewPrefill: widget.editItem == null,
                                  ),
                                ),
                              );
                            },
                      child: locationProvider.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Confirm Location & Proceed',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── GPS current location floating action button ──────────────────
          Positioned(
            right: 16,
            bottom: 240, // Floating above the bottom card panel
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _initLocation,
              child: Icon(Icons.gps_fixed, color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
