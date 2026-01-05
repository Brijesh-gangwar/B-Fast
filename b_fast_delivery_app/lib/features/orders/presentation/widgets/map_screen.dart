import 'package:b_fast_delivery_app/features/orders/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  final LatLng currentLocation;
  final Address address;

  const MapScreen({super.key, required this.currentLocation, required this.address});

  @override
  State<MapScreen> createState() => _MapScreenState();
}


class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Static destination (example: Delhi)
  final LatLng destination = const LatLng(28.76776,79.49207);

  // Static/random address text
  final String currentAddress = "your location";
  final String destinationAddress = "";

  /// Opens Google Maps app for navigation
  Future<void> _openInGoogleMaps() async {
    print(widget.currentLocation);
    final Uri googleUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${widget.currentLocation.latitude},${widget.currentLocation.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&travelmode=driving',
    );

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open Google Maps.';
    }
  }

  /// Calculate midpoint between current location and destination
  LatLng _getCenter() {
    final double midLat =
        (widget.currentLocation.latitude + destination.latitude) / 2;
    final double midLng =
        (widget.currentLocation.longitude + destination.longitude) / 2;
    return LatLng(midLat, midLng);
  }

  /// Reset map to initial center
  void _resetMapView() {
    final LatLng center = _getCenter();
    _mapController.move(center, 10.5);
  }

  @override
  Widget build(BuildContext context) {
    final LatLng mapCenter = _getCenter();

    return Scaffold(
      appBar: AppBar(title: const Text("Map Screen")),
      body: Stack(
        children: [
          // OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: mapCenter,
              initialZoom: 10.5,
              maxZoom: 18,
              minZoom: 3,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.currentLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 38,
                    ),
                  ),
                  Marker(
                    point: destination,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 38,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Info Card (Static Text)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Route Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Divider(),
                    Text(
                      "📍 From: $currentAddress",
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "🏁 To: ${widget.address.label}, ${widget.address.street}, ${widget.address.city}, ${widget.address.zip}",
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Buttons
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _resetMapView,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset View"),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _openInGoogleMaps,
                  icon: const Icon(Icons.navigation),
                  label: const Text("Navigate"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
