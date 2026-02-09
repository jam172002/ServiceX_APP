import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../domain/models/location_model.dart';
import '../../../../utils/constants/colors.dart';

class LocationSelectorScreen extends StatefulWidget {
  const LocationSelectorScreen({super.key});

  @override
  State<LocationSelectorScreen> createState() => _LocationSelectorScreenState();
}

class _LocationSelectorScreenState extends State<LocationSelectorScreen> {
  GoogleMapController? _mapController;

  LatLng? _pickedLatLng;

  String _label = 'Home';

  final addressController = TextEditingController();
  final customLabelController = TextEditingController();

  static const LatLng _fallback = LatLng(24.8607, 67.0011);

  @override
  void dispose() {
    addressController.dispose();
    customLabelController.dispose();
    super.dispose();
  }

  // ──────────────────────────────
  // Location helpers
  // ──────────────────────────────

  Future<void> _reverseGeocode(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        addressController.text =
        '${p.street}, ${p.locality}, ${p.administrativeArea}, ${p.country}';
      }
    } catch (_) {}
  }

  Future<void> _useCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.snackbar('Permission required', 'Enable location permission');
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final latLng = LatLng(position.latitude, position.longitude);

    setState(() => _pickedLatLng = latLng);

    await _reverseGeocode(latLng);

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 16),
    );
  }

  void _onMapTap(LatLng latLng) async {
    setState(() => _pickedLatLng = latLng);
    await _reverseGeocode(latLng);
  }

  void _confirm() {
    if (_pickedLatLng == null || addressController.text.isEmpty) {
      Get.snackbar('Incomplete', 'Please pick a location');
      return;
    }

    final finalLabel =
    _label == 'Custom' ? customLabelController.text : _label;

    if (finalLabel.isEmpty) {
      Get.snackbar('Label required', 'Enter location label');
      return;
    }

    final location = LocationModel(
      label: finalLabel,
      address: addressController.text.trim(),
      lat: _pickedLatLng!.latitude,
      lng: _pickedLatLng!.longitude,
      isDefault: true,
    );

    Get.back(result: location);
  }

  // ──────────────────────────────
  // UI
  // ──────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: XColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // MAP
          Expanded(
            flex: 5,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _fallback,
                zoom: 14,
              ),
              myLocationEnabled: true,
              onMapCreated: (c) => _mapController = c,
              onTap: _onMapTap,
              markers: _pickedLatLng == null
                  ? {}
                  : {
                Marker(
                  markerId: const MarkerId('picked'),
                  position: _pickedLatLng!,
                ),
              },
            ),
          ),

          // CONTROLS
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // GPS
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.my_location),
                      label: const Text('Use Current Location'),
                      onPressed: _useCurrentLocation,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // LABEL
                  DropdownButtonFormField<String>(
                    initialValue: _label,
                    items: const [
                      DropdownMenuItem(value: 'Home', child: Text('Home')),
                      DropdownMenuItem(value: 'Office', child: Text('Office')),
                      DropdownMenuItem(value: 'Custom', child: Text('Custom')),
                    ],
                    onChanged: (v) => setState(() => _label = v!),
                    decoration: const InputDecoration(
                      labelText: 'Label',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  if (_label == 'Custom') ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: customLabelController,
                      decoration: const InputDecoration(
                        hintText: 'Enter label',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // ADDRESS
                  TextField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const Spacer(),

                  // CONFIRM
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: XColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Confirm Location',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
