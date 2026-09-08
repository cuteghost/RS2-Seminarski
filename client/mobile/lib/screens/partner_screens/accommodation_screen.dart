import 'package:ebooking/config/app_constants.dart';
import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/accommodation_model.dart';
import 'package:ebooking/models/city_model.dart';
import 'package:ebooking/models/country_model.dart';
import 'package:ebooking/models/location_model.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/providers/catalog_provider.dart';
import 'package:ebooking/providers/location_provider.dart';
import 'package:ebooking/widgets/asset_thumbnail.dart';
import 'package:ebooking/widgets/custom_partner_bottom_navigation_bar.dart';
import 'package:ebooking/widgets/remote_image.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AccommodationScreen extends StatefulWidget {
  final AccommodationGET accommodation;

  const AccommodationScreen({super.key, required this.accommodation});

  @override
  AccommodationScreenState createState() => AccommodationScreenState();
}

class AccommodationScreenState extends State<AccommodationScreen> {
  final ValueNotifier<bool> hasChanges = ValueNotifier<bool>(false);
  late AccommodationGET accommodation;

  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _numBedsController = TextEditingController();
  final _addressController = TextEditingController();
  final Set<String> _selectedAmenityIds = <String>{};
  final List<_Photo> _photos = <_Photo>[];
  String? _typeId;
  bool _isSaving = false;
  bool _photosReplaced = false;
  int _photoVersion = 0;
  bool _status = true;
  Country? _country;
  City? _city;
  bool _placesLoading = true;
  String? _placesError;
  bool _locationTouched = false;

  @override
  void initState() {
    super.initState();
    accommodation = widget.accommodation;
    _status = accommodation.status;
    _addressController.text = accommodation.location.address;
    _priceController.text = accommodation.pricePerNight.toString();
    _descriptionController.text = accommodation.description;
    _numBedsController.text = accommodation.accommodationDetails.numberOfBeds
        .toString();
    _typeId = accommodation.accommodationTypeId.isEmpty
        ? null
        : accommodation.accommodationTypeId;
    _selectedAmenityIds.addAll(
      accommodation.accommodationDetails.amenities.map((a) => a.id),
    );
    _photos.addAll(accommodation.imageUrls.map(_Photo.remote));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPlaces();
      if (!mounted) return;
      final catalog = Provider.of<CatalogProvider>(context, listen: false);
      await catalog.load();
      if (!mounted || catalog.error == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(catalog.error!)));
    });
  }

  /// Fills the country and city dropdowns and preselects the pair the listing
  /// already sits on. The stored location carries the country by name and the
  /// city by id, so the country is matched on its label and the city on its
  /// own identifier. Both selections are taken out of the fetched lists, never
  /// rebuilt, so the dropdowns always hold one of their own items.
  Future<void> _loadPlaces() async {
    final places = Provider.of<LocationProvider>(context, listen: false);

    await places.fetchCountries();
    if (!mounted) return;

    Country? country;
    for (final candidate in places.countries) {
      if (candidate.name == accommodation.location.countryName) {
        country = candidate;
        break;
      }
    }

    if (country == null) {
      setState(() {
        _placesLoading = false;
        _placesError = places.error;
      });
      return;
    }

    await places.fetchCities(country.id);
    if (!mounted) return;

    City? city;
    for (final candidate in places.cities) {
      if (candidate.id == accommodation.location.cityId) {
        city = candidate;
        break;
      }
    }

    setState(() {
      _country = country;
      _city = city;
      _placesLoading = false;
      _placesError = places.error;
    });
  }

  Future<void> _onCountryChanged(Country? picked) async {
    if (picked == null || picked.id == _country?.id) return;

    final places = Provider.of<LocationProvider>(context, listen: false);
    setState(() {
      _country = picked;
      // Dropped before the fetch: a city from the previous country is not in
      // the new list, and a value the list does not hold trips the dropdown.
      _city = null;
      _placesLoading = true;
      _locationTouched = true;
      hasChanges.value = true;
    });

    await places.fetchCities(picked.id);
    if (!mounted) return;

    setState(() {
      _placesLoading = false;
      _placesError = places.error;
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    _numBedsController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? get _locationProblem {
    if (!_locationTouched) return null;
    if (_country == null) return 'Pick the country this address belongs to.';
    if (_city == null) return 'Pick the city this address belongs to.';
    return null;
  }

  String? get _photoProblem {
    if (!_photosReplaced) return null;
    final missing = AccommodationPhotos.required - _photos.length;
    if (missing <= 0) return null;
    return 'A listing needs at least ${AccommodationPhotos.required} photos. '
        'Add $missing more before saving.';
  }

  Future<void> _addPhotos() async {
    final room = AccommodationPhotos.maximum - _photos.length;
    if (room <= 0) return;

    PermissionStatus status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
      if (!status.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Photo access is turned off, so the gallery cannot be opened. '
              'Allow it in the system settings and try again.',
            ),
          ),
        );
        return;
      }
    }
    if (!mounted) return;

    List<AssetEntity> picked = <AssetEntity>[];
    try {
      picked =
          await AssetPicker.pickAssets(
            context,
            pickerConfig: AssetPickerConfig(
              maxAssets: room,
              requestType: RequestType.image,
            ),
          ) ??
          <AssetEntity>[];
    } on Exception catch (_) {
      picked = <AssetEntity>[];
    }
    if (!mounted || picked.isEmpty) return;

    setState(() {
      _photos.addAll(picked.map(_Photo.picked));
      _photosReplaced = true;
      hasChanges.value = true;
    });
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
      _photosReplaced = true;
      hasChanges.value = true;
    });
  }

  Future<List<String>?> _encodePhotos(AccommodationProvider provider) async {
    final encoded = <String>[];
    for (final photo in _photos) {
      final url = photo.url;
      if (url != null) {
        encoded.add(
          AccommodationImages.encodeBytes(await provider.fetchImage(url)),
        );
        continue;
      }
      try {
        final file = await photo.asset!.file;
        if (file == null) return null;
        encoded.add(await AccommodationImages.encode(file));
      } on Exception catch (_) {
        return null;
      }
    }
    return encoded;
  }

  Future<void> _evictPhotoCache(AccommodationGET saved) async {
    final urls = <String>{...accommodation.imageUrls, ...saved.imageUrls};
    for (final url in urls) {
      await RemoteImage.evict(url);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final catalog = Provider.of<CatalogProvider>(context, listen: false);
    final provider = Provider.of<AccommodationProvider>(context, listen: false);
    final places = Provider.of<LocationProvider>(context, listen: false);
    final detailsToUpdate = AccommodationDetails(
      numberOfBeds: int.parse(_numBedsController.text),
      amenities: catalog.amenities
          .where((amenity) => _selectedAmenityIds.contains(amenity.id))
          .toList(),
    );

    String? failure;
    AccommodationGET? updated;
    try {
      AccommodationImages? replacement;
      if (_photosReplaced) {
        final encoded = await _encodePhotos(provider);
        if (encoded == null) {
          if (!mounted) return;
          setState(() => _isSaving = false);
          _tell(
            'Something went wrong',
            'One of the picked photos could not be read from the gallery. '
                'Remove it and pick another one.',
          );
          return;
        }
        replacement = AccommodationImages(base64Images: encoded);
      }

      // Only a touched address is geocoded and sent. Left alone, the server
      // keeps the coordinates it already has instead of looking them up again.
      Location? movedTo;
      if (_locationTouched) {
        final coordinates = await places.craftGeoCode(
          '${_addressController.text.trim()} ${_city!.name} ${_country!.name}',
        );
        movedTo = Location(
          latitude: coordinates[0],
          longitude: coordinates[1],
          address: _addressController.text.trim(),
          cityId: _city!.id,
        );
      }

      final patch = AccommodationPATCH(
        id: accommodation.id,
        status: _status,
        location: movedTo,
        images: replacement,
        // Fixes a bug: this used to send _nameController.text, but the Name
        // field was never wired to that controller (it wrote straight to
        // accommodation.name instead), so edits to the name were silently
        // dropped on save.
        name: accommodation.name,
        pricePerNight: double.parse(_priceController.text),
        description: _descriptionController.text,
        accommodationDetails: detailsToUpdate,
        accommodationTypeId: _typeId ?? accommodation.accommodationTypeId,
      );

      updated = await provider.updateAccommodation(patch);
    } on ApiException catch (e) {
      failure = e.message;
    }

    final saved = updated;
    if (saved != null) {
      if (_photosReplaced) await _evictPhotoCache(saved);
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        accommodation = saved;
        _status = saved.status;
        _addressController.text = saved.location.address;
        _locationTouched = false;
        _photos
          ..clear()
          ..addAll(saved.imageUrls.map(_Photo.remote));
        _photosReplaced = false;
        _photoVersion++;
      });
      hasChanges.value = false;
      _tell('Saved', 'Accommodation updated successfully.');
      return;
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    // Fixes a bug: failures used to call showAboutDialog (Flutter's
    // built-in "About this app" dialog) instead of an actual error dialog.
    // The text is now the server's own reason, not a generic sentence.
    _tell('Something went wrong', failure!);
  }

  void _tell(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final catalog = Provider.of<CatalogProvider>(context);
    final places = Provider.of<LocationProvider>(context);
    final photoProblem = _photoProblem;
    final locationProblem = _locationProblem;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Card(
                title: 'Basics',
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (value) {
                      hasChanges.value = true;
                      accommodation.name = value;
                    },
                    initialValue: accommodation.name,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Please enter a name' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: catalog.types.any((t) => t.id == _typeId)
                        ? _typeId
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      helperText: catalog.types.isEmpty
                          ? (catalog.isLoading
                                ? 'Loading the types...'
                                : catalog.error ?? 'No types are set up yet.')
                          : null,
                    ),
                    items: [
                      for (final type in catalog.types)
                        DropdownMenuItem<String>(
                          value: type.id,
                          child: Text(type.name),
                        ),
                    ],
                    onChanged: catalog.types.isEmpty
                        ? null
                        : (value) => setState(() {
                            _typeId = value;
                            hasChanges.value = true;
                          }),
                    validator: (value) =>
                        value == null ? 'Please pick a type' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price per night',
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => hasChanges.value = true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the price per night';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    onChanged: (_) => hasChanges.value = true,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Please enter a description'
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Card(
                title: 'Location',
                children: [
                  DropdownButtonFormField<Country>(
                    initialValue: _country,
                    decoration: InputDecoration(
                      labelText: 'Country',
                      helperText: places.countries.isEmpty
                          ? (_placesLoading
                                ? 'Loading the countries...'
                                : _placesError ??
                                      'No countries are set up yet.')
                          : null,
                    ),
                    hint: const Text('Select country'),
                    items: [
                      for (final country in places.countries)
                        DropdownMenuItem<Country>(
                          value: country,
                          child: Text(country.name),
                        ),
                    ],
                    onChanged: (_isSaving || places.countries.isEmpty)
                        ? null
                        : _onCountryChanged,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<City>(
                    initialValue: _city,
                    decoration: InputDecoration(
                      labelText: 'City',
                      helperText: places.cities.isEmpty
                          ? (_placesLoading
                                ? 'Loading the cities...'
                                : _country == null
                                ? 'Pick a country first.'
                                : _placesError ??
                                      'This country has no cities yet.')
                          : null,
                    ),
                    hint: const Text('Select city'),
                    items: [
                      for (final city in places.cities)
                        DropdownMenuItem<City>(
                          value: city,
                          child: Text(city.name),
                        ),
                    ],
                    onChanged: (_isSaving || places.cities.isEmpty)
                        ? null
                        : (value) => setState(() {
                            _city = value;
                            _locationTouched = true;
                            hasChanges.value = true;
                          }),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      helperText:
                          'Street and number, at most 200 characters. Saving '
                          'looks the address up and moves the pin.',
                    ),
                    onChanged: (_) {
                      _locationTouched = true;
                      hasChanges.value = true;
                    },
                    validator: (value) {
                      final address = value?.trim() ?? '';
                      if (address.isEmpty) return 'Please enter the address';
                      if (address.length > 200) {
                        return 'The address can be at most 200 characters';
                      }
                      return null;
                    },
                  ),
                  if (locationProblem != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      locationProblem,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppColors.radiusMd),
                    child: SizedBox(
                      height: 160,
                      child: maps.GoogleMap(
                        // The camera position is read once per map, so a saved
                        // move needs a new map to show the new pin.
                        key: ValueKey(
                          '${accommodation.location.latitude},'
                          '${accommodation.location.longitude}',
                        ),
                        initialCameraPosition: maps.CameraPosition(
                          target: maps.LatLng(
                            accommodation.location.latitude,
                            accommodation.location.longitude,
                          ),
                          zoom: 14,
                        ),
                        markers: {
                          maps.Marker(
                            markerId: maps.MarkerId(accommodation.name),
                            position: maps.LatLng(
                              accommodation.location.latitude,
                              accommodation.location.longitude,
                            ),
                          ),
                        },
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: false,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Card(
                title: 'Availability',
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _status,
                    title: Text(
                      _status ? 'Active' : 'Inactive',
                      style: textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      _status
                          ? 'Guests can find this listing and book it.'
                          : 'Guests cannot find or book this listing. It stays '
                                'on your own list.',
                      style: textTheme.bodySmall,
                    ),
                    onChanged: _isSaving
                        ? null
                        : (value) => setState(() {
                            _status = value;
                            hasChanges.value = true;
                          }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Card(
                title: 'Photos',
                children: [
                  Text(
                    'Saving replaces the whole set. The first '
                    '${AccommodationPhotos.required} are required and up to '
                    '${AccommodationPhotos.maximum} are kept.',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemCount:
                        _photos.length +
                        (_photos.length < AccommodationPhotos.maximum ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _photos.length) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(
                            AppColors.radiusMd,
                          ),
                          onTap: _isSaving ? null : _addPhotos,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(
                                AppColors.radiusMd,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              PhosphorIcons.plus(),
                              color: AppColors.textSecondary,
                              size: 22,
                            ),
                          ),
                        );
                      }
                      final photo = _photos[index];
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppColors.radiusMd,
                              ),
                              child: photo.url != null
                                  ? RemoteImage(
                                      key: ValueKey(
                                        '${photo.url}#$_photoVersion',
                                      ),
                                      path: photo.url,
                                    )
                                  : AssetThumbnail(asset: photo.asset!),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: _isSaving
                                  ? null
                                  : () => _removePhoto(index),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: AppColors.bg.withValues(alpha: 0.85),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  PhosphorIcons.x(),
                                  size: 12,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  if (photoProblem != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      photoProblem,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _Card(
                title: 'Amenities',
                children: [
                  TextFormField(
                    controller: _numBedsController,
                    decoration: const InputDecoration(
                      labelText: 'Number of beds',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => hasChanges.value = true,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Please enter the number of beds'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  if (catalog.amenities.isEmpty)
                    Text(
                      catalog.isLoading
                          ? 'Loading the amenity list...'
                          : catalog.error ??
                                'The amenity list is empty, so there is nothing to pick.',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: [
                        for (final amenity in catalog.amenities)
                          _AmenityToggle(
                            label: amenity.name,
                            selected: _selectedAmenityIds.contains(amenity.id),
                            onTap: () => setState(() {
                              if (!_selectedAmenityIds.remove(amenity.id)) {
                                _selectedAmenityIds.add(amenity.id);
                              }
                              hasChanges.value = true;
                            }),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<bool>(
                valueListenable: hasChanges,
                builder: (context, value, child) {
                  return OutlinedButton(
                    onPressed:
                        (value &&
                            !_isSaving &&
                            photoProblem == null &&
                            locationProblem == null)
                        ? _save
                        : null,
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save changes'),
                  );
                },
              ),
              if (photoProblem != null) ...[
                const SizedBox(height: 8),
                Text(
                  photoProblem,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ],
              if (locationProblem != null) ...[
                const SizedBox(height: 8),
                Text(
                  locationProblem,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomPartnerBottomNavigationBar(
        currentIndex: 0,
      ),
    );
  }
}

class _Photo {
  _Photo.remote(String this.url) : asset = null;
  _Photo.picked(AssetEntity this.asset) : url = null;

  final String? url;
  final AssetEntity? asset;
}

class _Card extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Card({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _AmenityToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AmenityToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentTint : null,
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(
                PhosphorIcons.check(),
                size: 13,
                color: AppColors.accentText,
              ),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: selected ? AppColors.accentText : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
