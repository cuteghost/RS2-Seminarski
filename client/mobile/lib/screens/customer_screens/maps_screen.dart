import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  late Position userLocation; // Store user's current location
  Future? _initMapFuture;
  List<AccommodationGET> _nearbyAccommodations = [];

  @override
  void initState() {
    super.initState();
    _initMapFuture = initMap().then((_) {
      _getNearbyAccommodations().then((value) {
        setState(() {
          _nearbyAccommodations = value;
        });
      });
    });
  }

  Future<List<AccommodationGET>> _getNearbyAccommodations() async {
    var nearby =
        await Provider.of<AccommodationProvider>(context, listen: false)
            .fetchNearbyAccommodations(
                userLocation.latitude, userLocation.longitude);
    return nearby;
  }

  Future<void> initMap() async {
    await _requestLocationPermission();
    Position? location = await _getUserLocation();

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
    }
  }

  Future<Position?> _getUserLocation() async {
    try {
      Position userLocation = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return userLocation;
    } catch (e) {
      // Handle the case where location services are disabled or an error occurs
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initMapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              appBar: AppBar(
                title: Text('Map'),
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
              bottomNavigationBar: CustomBottomNavigationBar());
        } else {
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
                  target: LatLng(
                      userLocation.latitude,
                      userLocation
                          .longitude), // Default to San Francisco's coordinates
                  zoom: 15.0,
                ),
                // Add markers for user's current location and nearby properties
                markers: _buildMarkers(),
              ),
              bottomNavigationBar: CustomBottomNavigationBar());
        }
      },
    );
  }

  Set<Marker> _buildMarkers() {
    // Add markers for user's current location and nearby properties
    Set<Marker> markers = {};

    // Marker for user's current location
    markers.add(
      Marker(
        markerId: MarkerId('user_location'),
        position: LatLng(
          userLocation.latitude,
          userLocation.longitude,
        ),
        infoWindow: InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        flat: true,
      ),
    );

    // Add markers for nearby properties
    // Replace these coordinates with the actual coordinates of nearby properties
    for (var accommodation in _nearbyAccommodations) {
      markers.add(
        Marker(
          markerId: MarkerId(accommodation.name),
          position: LatLng(accommodation.location.latitude,
              accommodation.location.longitude),
          infoWindow: InfoWindow(
              title: accommodation.name,
              snippet: 'Price: \$${accommodation.pricePerNight}'),
        ),
      );
    }

    return markers;
  }
}
