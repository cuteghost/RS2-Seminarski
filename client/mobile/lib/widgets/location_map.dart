import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/config/map_style.dart';
import 'package:ebooking/models/location_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class LocationMap extends StatelessWidget {
  final Location location;
  final String markerTitle;
  final double height;

  const LocationMap({
    super.key,
    required this.location,
    required this.markerTitle,
    this.height = 170,
  });

  bool get _hasPlottableCoordinates {
    final latitude = location.latitude;
    final longitude = location.longitude;
    if (!latitude.isFinite || !longitude.isFinite) return false;
    if (latitude.abs() > 90 || longitude.abs() > 180) return false;
    return latitude != 0 || longitude != 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPlottableCoordinates) {
      return _MapUnavailable(height: height, address: location.address);
    }

    final target = LatLng(location.latitude, location.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: height,
        width: double.infinity,
        color: AppColors.surface,
        child: GoogleMap(
          style: kDarkMapStyle,
          initialCameraPosition: CameraPosition(target: target, zoom: 14),
          markers: {
            Marker(
              markerId: const MarkerId('accommodation_location'),
              position: target,
              infoWindow: InfoWindow(title: markerTitle),
            ),
          },
          zoomControlsEnabled: true,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
        ),
      ),
    );
  }
}

class _MapUnavailable extends StatelessWidget {
  final double height;
  final String address;

  const _MapUnavailable({required this.height, required this.address});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.mapPinLine(),
              size: 26,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 10),
            Text(
              'Map unavailable',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              address,
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
