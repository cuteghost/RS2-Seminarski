import 'dart:io';

import 'package:ebooking/config/app_constants.dart';
import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/accommodation_model.dart';
import 'package:ebooking/models/city_model.dart';
import 'package:ebooking/models/country_model.dart';
import 'package:ebooking/models/location_model.dart';
import 'package:ebooking/models/catalog_model.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/providers/catalog_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebooking/providers/location_provider.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ebooking/widgets/asset_thumbnail.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class AddAccommodationScreen extends StatefulWidget {
  const AddAccommodationScreen({super.key});

  @override
  AddAccommodationScreenState createState() => AddAccommodationScreenState();
}

class AddAccommodationScreenState extends State<AddAccommodationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _bedsController = TextEditingController();

  final Set<String> _selectedAmenityIds = <String>{};
  String? _typeId;

  City? _selectedCity;
  Country? _selectedCountry;
  List<AssetEntity> images = <AssetEntity>[];
  int _currentStep = 0;
  bool _isSubmitting = false;

  static const _stepTitles = ['Basics', 'Location', 'Amenities', 'Photos'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );
      final catalog = Provider.of<CatalogProvider>(context, listen: false);
      await Future.wait<void>([
        locationProvider.fetchCountries(),
        catalog.load(),
      ]);
      // An empty dropdown has to say why it is empty.
      if (!mounted) return;
      final problem = locationProvider.error ?? catalog.error;
      if (problem == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(problem)));
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _bedsController.dispose();
    super.dispose();
  }

  Future<void> loadImages() async {
    final room = AccommodationPhotos.maximum - images.length;
    if (room <= 0) return;

    PermissionStatus status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
      if (!status.isGranted) return;
    }

    List<AssetEntity> resultList = <AssetEntity>[];
    if (!mounted) return;
    try {
      resultList =
          await AssetPicker.pickAssets(
            context,
            pickerConfig: AssetPickerConfig(
              maxAssets: room,
              requestType: RequestType.image,
              selectedAssets: const [],
            ),
          ) ??
          [];
    } on Exception catch (_) {
      // Ignore picker errors — user may have cancelled
    }
    if (!mounted) return;
    setState(() => images = [...images, ...resultList]);
  }

  bool get _locationValid =>
      _selectedCountry != null &&
      _selectedCity != null &&
      _addressController.text.isNotEmpty;

  void _goNext() {
    if (_currentStep == 0) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
    }
    if (_currentStep == 1) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      if (!_locationValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a country and city.')),
        );
        return;
      }
    }
    if (_currentStep == 3) {
      _submit();
      return;
    }
    setState(() => _currentStep++);
  }

  Future<void> _submit() async {
    final typeId = _typeId;
    if (typeId == null) {
      setState(() => _currentStep = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a type of accommodation.')),
      );
      return;
    }
    if (images.length < AccommodationPhotos.required) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'A listing needs at least ${AccommodationPhotos.required} photos. '
            'Add ${AccommodationPhotos.required - images.length} more before '
            'publishing.',
          ),
        ),
      );
      return;
    }
    if (_bedsController.text.isEmpty) {
      setState(() => _currentStep = 2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the number of beds.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );
      final accommodationProvider = Provider.of<AccommodationProvider>(
        context,
        listen: false,
      );
      final catalog = Provider.of<CatalogProvider>(context, listen: false);

      final coords = await locationProvider.craftGeoCode(
        '${_addressController.text} ${_selectedCity?.name} ${_selectedCountry?.name}',
      );

      final location = Location(
        latitude: coords[0],
        longitude: coords[1],
        address: _addressController.text,
        cityId: _selectedCity?.id ?? '',
      );

      final files = await Future.wait(images.map((e) => e.file));
      final accommodationImages = AccommodationImages(
        base64Images: await Future.wait(
          files.whereType<File>().map(
            (file) => AccommodationImages.encode(file),
          ),
        ),
      );

      final accommodation = AccommodationPOST(
        images: accommodationImages,
        name: _nameController.text.trim(),
        pricePerNight: double.parse(_priceController.text),
        description: _descriptionController.text,
        location: location,
        accommodationTypeId: typeId,
        accommodationDetails: AccommodationDetails(
          numberOfBeds: int.parse(_bedsController.text),
          amenities: catalog.amenities
              .where((amenity) => _selectedAmenityIds.contains(amenity.id))
              .toList(),
        ),
      );

      // Awaited now: the call used to be fired and forgotten, so the screen
      // announced a published listing whatever the server answered.
      await accommodationProvider.addAccommodation(accommodation);
      if (!mounted) return;

      // Unlike the old handler (which posted and silently stayed on the
      // form), confirm success and return to the listings screen so the
      // partner can see the new property landed.
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Listing published'),
          content: Text('${_nameController.text.trim()} is now live.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            _currentStep == 0 ? PhosphorIcons.x() : PhosphorIcons.arrowLeft(),
          ),
          onPressed: () {
            if (_currentStep == 0) {
              Navigator.pop(context);
            } else {
              setState(() => _currentStep--);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_stepTitles[_currentStep]),
            Text(
              'Step ${_currentStep + 1} of 4',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: List.generate(4, (i) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i == 3 ? 0 : 5),
                    height: 3,
                    decoration: BoxDecoration(
                      color: i <= _currentStep
                          ? AppColors.accent
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: _buildStep(textTheme),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                if (_currentStep == 2)
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Text(
                      '${_selectedAmenityIds.length} selected',
                      style: textTheme.bodySmall,
                    ),
                  ),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : _goNext,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_currentStep == 3 ? 'Publish listing' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(TextTheme textTheme) {
    switch (_currentStep) {
      case 0:
        return _BasicsStep(
          nameController: _nameController,
          priceController: _priceController,
          descriptionController: _descriptionController,
          types: Provider.of<CatalogProvider>(context).types,
          typeId: _typeId,
          onTypeChanged: (value) => setState(() => _typeId = value),
        );
      case 1:
        return _LocationStep(
          addressController: _addressController,
          selectedCountry: _selectedCountry,
          selectedCity: _selectedCity,
          onCountryChanged: (country) async {
            setState(() {
              _selectedCountry = country;
              _selectedCity = null;
            });
            if (country != null) {
              await Provider.of<LocationProvider>(
                context,
                listen: false,
              ).fetchCities(country.id);
            }
          },
          onCityChanged: (city) => setState(() => _selectedCity = city),
        );
      case 2:
        final catalog = Provider.of<CatalogProvider>(context);
        return _AmenitiesStep(
          amenities: catalog.amenities,
          selectedIds: _selectedAmenityIds,
          isLoading: catalog.isLoading,
          error: catalog.error,
          bedsController: _bedsController,
          onToggle: (id) => setState(() {
            if (!_selectedAmenityIds.remove(id)) _selectedAmenityIds.add(id);
          }),
        );
      default:
        return _PhotosStep(
          images: images,
          onAdd: loadImages,
          onRemove: (index) => setState(() => images.removeAt(index)),
        );
    }
  }
}

class _BasicsStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final List<AccommodationType> types;
  final String? typeId;
  final ValueChanged<String?> onTypeChanged;

  const _BasicsStep({
    required this.nameController,
    required this.priceController,
    required this.descriptionController,
    required this.types,
    required this.typeId,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          // Trimmed: a name of nothing but spaces used to pass this step and
          // reach the server as a blank listing title.
          validator: (value) => (value ?? '').trim().isEmpty
              ? 'Please enter a name'
              : null,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: types.any((type) => type.id == typeId) ? typeId : null,
          decoration: InputDecoration(
            labelText: 'Type',
            helperText: types.isEmpty
                ? 'The type list has not loaded yet.'
                : null,
          ),
          items: [
            for (final type in types)
              DropdownMenuItem<String>(value: type.id, child: Text(type.name)),
          ],
          onChanged: types.isEmpty ? null : onTypeChanged,
          validator: (value) => value == null ? 'Please pick a type' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: priceController,
          decoration: const InputDecoration(
            labelText: 'Price per night',
            prefixText: '\$ ',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter a price';
            if (double.tryParse(value) == null) return 'Enter a valid number';
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
          maxLines: 4,
          validator: (value) => (value == null || value.isEmpty)
              ? 'Please enter a description'
              : null,
        ),
      ],
    );
  }
}

class _LocationStep extends StatelessWidget {
  final TextEditingController addressController;
  final Country? selectedCountry;
  final City? selectedCity;
  final ValueChanged<Country?> onCountryChanged;
  final ValueChanged<City?> onCityChanged;

  const _LocationStep({
    required this.addressController,
    required this.selectedCountry,
    required this.selectedCity,
    required this.onCountryChanged,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final countries = Provider.of<LocationProvider>(
      context,
      listen: true,
    ).countries;
    final cities = Provider.of<LocationProvider>(context, listen: true).cities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<Country>(
          initialValue: selectedCountry,
          decoration: const InputDecoration(labelText: 'Country'),
          hint: const Text('Select country'),
          onChanged: onCountryChanged,
          items: countries
              .map<DropdownMenuItem<Country>>(
                (c) => DropdownMenuItem(value: c, child: Text(c.name)),
              )
              .toList(),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<City>(
          initialValue: selectedCity,
          decoration: const InputDecoration(labelText: 'City'),
          hint: const Text('Select city'),
          onChanged: onCityChanged,
          items: cities
              .map<DropdownMenuItem<City>>(
                (c) => DropdownMenuItem(value: c, child: Text(c.name)),
              )
              .toList(),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: addressController,
          decoration: const InputDecoration(labelText: 'Address'),
          validator: (value) => (value == null || value.isEmpty)
              ? 'Please enter the address'
              : null,
        ),
      ],
    );
  }
}

class _AmenitiesStep extends StatelessWidget {
  final List<Amenity> amenities;
  final Set<String> selectedIds;
  final bool isLoading;
  final String? error;
  final TextEditingController bedsController;
  final void Function(String id) onToggle;

  const _AmenitiesStep({
    required this.amenities,
    required this.selectedIds,
    required this.isLoading,
    required this.error,
    required this.bedsController,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: bedsController,
          decoration: const InputDecoration(labelText: 'Number of beds'),
          keyboardType: TextInputType.number,
          validator: (value) => (value == null || value.isEmpty)
              ? 'Please enter the number of beds'
              : null,
        ),
        const SizedBox(height: 20),
        Text(
          'Tap everything your place offers. Guests filter on these.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        if (amenities.isEmpty)
          Text(
            isLoading
                ? 'Loading the amenity list...'
                : error ??
                      'The amenity list is empty, so there is nothing to pick.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
          )
        else
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              for (final amenity in amenities)
                _AmenityToggle(
                  label: amenity.name,
                  selected: selectedIds.contains(amenity.id),
                  onTap: () => onToggle(amenity.id),
                ),
            ],
          ),
      ],
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

class _PhotosStep extends StatelessWidget {
  final List<AssetEntity> images;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  const _PhotosStep({
    required this.images,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add at least ${AccommodationPhotos.required} photos; '
          '${AccommodationPhotos.maximum} is the most a listing can hold.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount:
              images.length +
              (images.length < AccommodationPhotos.maximum ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == images.length) {
              return InkWell(
                borderRadius: BorderRadius.circular(AppColors.radiusMd),
                onTap: onAdd,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppColors.radiusMd),
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
            return Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppColors.radiusMd),
                    child: AssetThumbnail(asset: images[index]),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => onRemove(index),
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
      ],
    );
  }
}
