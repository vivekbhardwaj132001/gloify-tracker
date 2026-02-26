import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_app/providers/location_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MapRouteScreen extends ConsumerStatefulWidget {
  final int sessionId;
  final Map<String, dynamic> startLoc;
  final Map<String, dynamic> endLoc;

  const MapRouteScreen({
    super.key,
    required this.sessionId,
    required this.startLoc,
    required this.endLoc,
  });

  @override
  ConsumerState<MapRouteScreen> createState() => _MapRouteScreenState();
}

class _MapRouteScreenState extends ConsumerState<MapRouteScreen> {
  GoogleMapController? _mapController;

  Future<void> _launchExternalMap() async {
    final startLat = widget.startLoc['lat'];
    final startLng = widget.startLoc['lng'];
    final endLat = widget.endLoc['lat'];
    final endLng = widget.endLoc['lng'];
    
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final routePointsAsync = ref.watch(routePointsProvider(widget.sessionId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Route Map', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.navigation),
            onPressed: _launchExternalMap,
            tooltip: 'Navigate Externally',
          ),
        ],
      ),
      body: routePointsAsync.when(
        data: (locations) {
          if (locations.isEmpty) {
            return const Center(child: Text('No location found for this trip.'));
          }

          Set<Polyline> polylines = {};
          List<LatLng> points = locations
              .map((loc) => LatLng(loc.latitude, loc.longitude))
              .toList();

          polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              color: Colors.blue,
              width: 5,
              points: points,
            ),
          );

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: points.isNotEmpty 
                  ? LatLng(locations.first.latitude, locations.first.longitude) 
                  : const LatLng(0, 0),
              zoom: 14,
            ),
            polylines: polylines,
            markers: {
              Marker(
                markerId: const MarkerId('start'),
                position: LatLng(widget.startLoc['lat'], widget.startLoc['lng']),
                infoWindow: const InfoWindow(title: 'Start Location'),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              ),
              Marker(
                markerId: const MarkerId('end'),
                position: LatLng(widget.endLoc['lat'], widget.endLoc['lng']),
                infoWindow: const InfoWindow(title: 'End Location'),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
            },
            onMapCreated: (controller) {
              _mapController = controller;
              // Add a slight delay to ensure map is ready before setting bounds
              Future.delayed(const Duration(milliseconds: 500), () {
                if (points.isNotEmpty && _mapController != null) {
                  LatLngBounds bounds = _getBounds(points);
                  _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
                }
              });
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading route: $err')),
      ),
    );
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in points) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }
}
