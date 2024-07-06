import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/widgets/CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  late LocationData userLocation; // Store user's current location
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
    if(userLocation != null){
      var nearby = await Provider.of<AccommodationProvider>(context, listen: false)
          .fetchNearbyAccommodations(userLocation.latitude!, userLocation.longitude!);
     return nearby;
    }
    else {
      print('Current position is null');
      List<AccommodationGET> empty = [];
      return empty;
    }
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
      print('Location permission is not granted');
    }
  }

  Future<LocationData?> _getUserLocation() async {
    Location location = Location();

    try {
      LocationData? userLocation = await location.getLocation();
      print('Got User location $userLocation');
      return userLocation;
    } catch (e) {
      // Handle the case where location services are disabled or an error occurs
      print('Error getting location: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder 
    ( 
      future: _initMapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold (
            appBar: AppBar (
               title: Text('Map'),
               ),
            body: Center (
              child: CircularProgressIndicator(),
            ),
            bottomNavigationBar: CustomBottomNavigationBar()
          );
        }
        else {
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
                zoom: 15.0,
              ),
              // Add markers for user's current location and nearby properties
              markers: _buildMarkers(),
            ),
            bottomNavigationBar: CustomBottomNavigationBar()
          );
        }
      },
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
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        flat: true,
      ),
    );

    // Add markers for nearby properties
    // Replace these coordinates with the actual coordinates of nearby properties
    for(var accommodation in _nearbyAccommodations) {
      markers.add(
        Marker(
          markerId: MarkerId(accommodation.name),
          position: LatLng(accommodation.location.latitude, accommodation.location.longitude),
          infoWindow: InfoWindow(title: accommodation.name, snippet: 'Price: \$${accommodation.pricePerNight}'),
        ),
      );
    }

    return markers;
  }
}
