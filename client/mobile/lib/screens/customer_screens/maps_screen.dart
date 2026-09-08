import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/config/map_style.dart';
import 'package:ebooking/models/accommodation_model.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/screens/customer_screens/accommodation_details_screen.dart';
import 'package:ebooking/widgets/custom_bottom_navigation_bar.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Position? _userLocation;
  bool _locationDenied = false;
  Future? _initMapFuture;
  List<AccommodationGET> _nearbyAccommodations = [];

  @override
  void initState() {
    super.initState();
    _initMapFuture = initMap().then((_) => _loadNearby());
  }

  /// A failed lookup leaves the map itself usable and says why instead of
  /// throwing into the framework, where the error had nowhere to surface.
  Future<void> _loadNearby() async {
    if (_userLocation == null) return;
    try {
      final nearby =
          await Provider.of<AccommodationProvider>(
            context,
            listen: false,
          ).fetchNearbyAccommodations(
            _userLocation!.latitude,
            _userLocation!.longitude,
          );
      if (!mounted) return;
      setState(() => _nearbyAccommodations = nearby);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> initMap() async {
    await Permission.location.request();
    final location = await _getUserLocation();
    if (!mounted) return;
    setState(() {
      _userLocation = location;
      _locationDenied = location == null;
    });
  }

  Future<Position?> _getUserLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initMapFuture,
      builder: (context, snapshot) {
        Widget body;
        if (snapshot.connectionState == ConnectionState.waiting) {
          body = const Center(child: CircularProgressIndicator());
        } else if (_locationDenied || _userLocation == null) {
          // Fixes a crash: the old version force-used `userLocation` here
          // even when permission was denied or location services were off,
          // which threw a LateInitializationError. Now it shows a message
          // instead of taking down the screen.
          final textTheme = Theme.of(context).textTheme;
          body = Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIcons.mapPinLine(),
                    size: 32,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 14),
                  Text('Location unavailable', style: textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Enable location access for this app in your device settings to see the map.',
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        } else {
          body = GoogleMap(
            style: kDarkMapStyle,
            initialCameraPosition: CameraPosition(
              target: LatLng(_userLocation!.latitude, _userLocation!.longitude),
              zoom: 15.0,
            ),
            markers: _buildMarkers(),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Map')),
          body: body,
          bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
        );
      },
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(_userLocation!.latitude, _userLocation!.longitude),
        infoWindow: const InfoWindow(title: 'Your location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };

    for (var accommodation in _nearbyAccommodations) {
      markers.add(
        Marker(
          markerId: MarkerId(accommodation.id),
          position: LatLng(
            accommodation.location.latitude,
            accommodation.location.longitude,
          ),
          infoWindow: InfoWindow(
            title: accommodation.name,
            snippet:
                '\$${accommodation.pricePerNight.toStringAsFixed(0)} / night',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccommodationDetailsScreen(
                    accommodation: accommodation,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return markers;
  }
}
