

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:b_fast_user_app/models/address_model.dart';
import 'package:b_fast_user_app/providers/address_provider.dart';
import '../../models/user_details_model.dart';
import '../snackbar_fxn.dart';

class AddressFormSheet extends StatefulWidget {
  final Addresses? existingAddress;

  const AddressFormSheet({super.key, this.existingAddress});

  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
  late final TextEditingController labelController;
  late final TextEditingController streetController;
  late final TextEditingController cityController;
  late final TextEditingController stateController;
  late final TextEditingController zipController;
  late final TextEditingController countryController;
  late final TextEditingController latitudeController;
  late final TextEditingController longitudeController;

  final ValueNotifier<bool> isFetchingLocation = ValueNotifier(false);
  final ValueNotifier<bool> isSaving = ValueNotifier(false);
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController(text: widget.existingAddress?.label ?? '');
    streetController = TextEditingController(text: widget.existingAddress?.street ?? '');
    cityController = TextEditingController(text: widget.existingAddress?.city ?? '');
    stateController = TextEditingController(text: widget.existingAddress?.state ?? '');
    zipController = TextEditingController(text: widget.existingAddress?.zip ?? '');
    countryController = TextEditingController(text: widget.existingAddress?.country ?? '');
    latitudeController = TextEditingController(text: widget.existingAddress?.latitude ?? '');
    longitudeController = TextEditingController(text: widget.existingAddress?.longitude ?? '');
  }

  /// Ensure location services are enabled and permissions granted
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("Location services enabled: $serviceEnabled");

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print("Location services enabled after opening settings: $serviceEnabled");
      if (!serviceEnabled) throw 'Location services are disabled. Enable them and try again.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    print("Initial location permission: $permission");

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print("Location permission after request: $permission");
      if (permission == LocationPermission.denied) throw 'Location permission denied.';
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      permission = await Geolocator.checkPermission();
      print("Location permission after opening app settings: $permission");
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        throw 'Location permission permanently denied. Grant it in Settings.';
      }
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print("Fetched position: Latitude=${position.latitude}, Longitude=${position.longitude}");
    return position;
  }

  /// Reverse-geocode coordinates to fill city, state, ZIP, country
  Future<void> _reverseGeocodeAndFill(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return;
      final p = placemarks.first;

      final streetParts = <String?>[p.street]
          .where((s) => (s ?? '').trim().isNotEmpty)
          .cast<String>()
          .toList();

      setState(() {
        streetController.text = streetParts.join(', ');
        cityController.text = (p.locality ?? p.subAdministrativeArea ?? '').trim();
        stateController.text = (p.administrativeArea ?? '').trim();
        zipController.text = (p.postalCode ?? '').trim();
        countryController.text = (p.country ?? '').trim();
      });

      // Debug: print auto-filled fields
      print("Auto-filled Address Details:");
      print("Street: ${streetController.text}");
      print("City: ${cityController.text}");
      print("State: ${stateController.text}");
      print("ZIP: ${zipController.text}");
      print("Country: ${countryController.text}");
    } catch (e) {
      if (mounted) {
        showCustomMessage(context,"Reverse geocoding failed: $e");
      }
      print("Error in reverse geocoding: $e");
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (!readOnly && (value == null || value.isEmpty)) return 'This field cannot be empty';
        return null;
      },
    );
  }

  Widget _buildLocationStatus() {
    final locationIsFetched = latitudeController.text.isNotEmpty && longitudeController.text.isNotEmpty;

    if (locationIsFetched) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Location Fetched', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            TextButton(
              onPressed: _fetchLocation,
              child: const Text('Fetch Again'),
            ),
          ],
        ),
      );
    } else {
      return ValueListenableBuilder<bool>(
        valueListenable: isFetchingLocation,
        builder: (_, fetching, __) {
          return OutlinedButton.icon(
            onPressed: fetching ? null : _fetchLocation,
            icon: fetching
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location),
            label: Text(fetching ? "Fetching..." : "Use Current Location"),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      );
    }
  }

  Future<void> _fetchLocation() async {
    isFetchingLocation.value = true;
    try {
      final position = await _determinePosition();
      setState(() {
        latitudeController.text = position.latitude.toString();
        longitudeController.text = position.longitude.toString();
      });
      await _reverseGeocodeAndFill(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) {
        showCustomMessage(context,"Failed to fetch location: $e");
      }
      print("Error fetching location: $e");
    } finally {
      isFetchingLocation.value = false;
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    isSaving.value = true;
    try {
      // Debug: print all fields before saving
      print("Saving Address:");
      print("Label: ${labelController.text}");
      print("Street: ${streetController.text}");
      print("City: ${cityController.text}");
      print("State: ${stateController.text}");
      print("ZIP: ${zipController.text}");
      print("Country: ${countryController.text}");
      print("Latitude: ${latitudeController.text}");
      print("Longitude: ${longitudeController.text}");

      if (widget.existingAddress == null) {
        final newAddress = UserAddress(
          label: labelController.text,
          street: streetController.text,
          city: cityController.text,
          state: stateController.text,
          zip: zipController.text,
          country: countryController.text,
          latitude: latitudeController.text,
          longitude: longitudeController.text,
        );
        await Provider.of<AddressProvider>(context, listen: false).addAddress(newAddress);
      } else {
        final updatedAddress = Addresses(
          addressId: widget.existingAddress!.addressId,
          label: labelController.text,
          street: streetController.text,
          city: cityController.text,
          state: stateController.text,
          zip: zipController.text,
          country: countryController.text,
          latitude: latitudeController.text,
          longitude: longitudeController.text,
        );
        await Provider.of<AddressProvider>(context, listen: false).updateAddress(updatedAddress);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showCustomMessage(context,"Save failed: $e");
      }
      print("Error saving address: $e");
    } finally {
      isSaving.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.existingAddress == null ? "Add a New Address" : "Update Address",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                  controller: labelController,
                  label: 'Label (e.g., Home, Work)',
                  icon: Icons.label_outline),
              const SizedBox(height: 12),
              _buildTextField(
                  controller: streetController,
                  label: 'Street Address',
                  icon: Icons.home_work_outlined),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          controller: cityController, label: 'City', icon: Icons.location_city)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildTextField(
                          controller: stateController, label: 'State', icon: Icons.map_outlined)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          controller: zipController,
                          label: 'ZIP / Pincode',
                          icon: Icons.markunread_mailbox_outlined)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildTextField(
                          controller: countryController,
                          label: 'Country',
                          icon: Icons.public_outlined)),
                ],
              ),
              const SizedBox(height: 16),
              _buildLocationStatus(),
              const SizedBox(height: 24),
              ValueListenableBuilder<bool>(
                valueListenable: isSaving,
                builder: (_, saving, __) {
                  return ElevatedButton(
                    onPressed: saving ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                        : Text(widget.existingAddress == null ? "Save Address" : "Update Address"),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
