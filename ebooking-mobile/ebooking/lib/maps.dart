import 'package:ebooking/widgets/CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  late LocationData userLocation; // Store user's current location

  @override
  void initState() {
    super.initState();
    initMap();
  }

  Future<void> initMap() async {
    await _requestLocationPermission();
    LocationData? location = await _getUserLocation();

    if (location != null) {
      setState(() {
        userLocation = location;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      // Permission has been granted
      // Now you can proceed to get the location
    } else {
      // Permission denied
      // Handle this case, show a message to the user or request permission again
    }
  }

  Future<LocationData?> _getUserLocation() async {
    Location location = Location();

    try {
      return await location.getLocation();
    } catch (e) {
      // Handle the case where location services are disabled or an error occurs
      print('Error getting location: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
        initialCameraPosition: CameraPosition(
          target: userLocation != null
              ? LatLng(userLocation.latitude!, userLocation.longitude!)
              : LatLng(37.7749, -122.4194), // Default to San Francisco's coordinates
          zoom: 12.0,
        ),
        // Add markers for user's current location and nearby properties
        markers: _buildMarkers(),
      ),
      bottomNavigationBar: CustomBottomNavigationBar()
    );
  }

  Set<Marker> _buildMarkers() {
    // Add markers for user's current location and nearby properties
    Set<Marker> markers = Set();

    // Marker for user's current location
    markers.add(
      Marker(
        markerId: MarkerId('user_location'),
        position: LatLng(
          userLocation != null ? userLocation.latitude! : 37.7749,
          userLocation != null ? userLocation.longitude! : -122.4194,
        ),
        infoWindow: InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Add markers for nearby properties
    // Replace these coordinates with the actual coordinates of nearby properties
    markers.add(
      Marker(
        markerId: MarkerId('property_1'),
        position: LatLng(37.7751, -122.4196),
        infoWindow: InfoWindow(title: 'Property 1'),
      ),
    );

    markers.add(
      Marker(
        markerId: MarkerId('property_2'),
        position: LatLng(37.7748, -122.4192),
        infoWindow: InfoWindow(title: 'Property 2'),
      ),
    );

    return markers;
  }
}
