import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/widgets/custom_partner_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

const Map<String, List<String>> _amenityGroups = {
  'Bathroom': ['Private Bathroom', 'Bathtub', 'Spa Tub'],
  'Outdoor': ['Terrace', 'Balcony', 'Private Pool', 'Sea View', 'View'],
  'Inside': ['Air Conditioning', 'Kitchen', 'Coffee Machine', 'Washing Machine', 'Soundproof'],
  'Meals': ['Breakfast'],
};

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
  final _accommodationDetails = <String, bool>{
    'Bathtub': false,
    'Balcony': false,
    'Private Bathroom': false,
    'Air Conditioning': false,
    'Terrace': false,
    'Kitchen': false,
    'Private Pool': false,
    'Coffee Machine': false,
    'View': false,
    'Sea View': false,
    'Washing Machine': false,
    'Spa Tub': false,
    'Soundproof': false,
    'Breakfast': false,
  };
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    accommodation = widget.accommodation;
    _priceController.text = accommodation.pricePerNight.toString();
    _descriptionController.text = accommodation.description;
    _numBedsController.text = accommodation.accommodationDetails.numberOfBeds.toString();
    final d = accommodation.accommodationDetails;
    _accommodationDetails['Bathtub'] = d.bathub;
    _accommodationDetails['Balcony'] = d.balcony;
    _accommodationDetails['Private Bathroom'] = d.privateBathroom;
    _accommodationDetails['Air Conditioning'] = d.ac;
    _accommodationDetails['Terrace'] = d.terrace;
    _accommodationDetails['Kitchen'] = d.kitchen;
    _accommodationDetails['Private Pool'] = d.privatePool;
    _accommodationDetails['Coffee Machine'] = d.coffeeMachine;
    _accommodationDetails['View'] = d.view;
    _accommodationDetails['Sea View'] = d.seaView;
    _accommodationDetails['Washing Machine'] = d.washingMachine;
    _accommodationDetails['Spa Tub'] = d.spaTub;
    _accommodationDetails['Soundproof'] = d.soundProof;
    _accommodationDetails['Breakfast'] = d.breakfast;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    _numBedsController.dispose();
    super.dispose();
  }

  Future<void> _addImages() async {
    PermissionStatus status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
      if (!status.isGranted) return;
    }

    List<AssetEntity> picked = <AssetEntity>[];
    if (!mounted) return;
    try {
      picked = await AssetPicker.pickAssets(
            context,
            pickerConfig: const AssetPickerConfig(
              maxAssets: 20,
              requestType: RequestType.image,
              selectedAssets: [],
            ),
          ) ??
          [];
    } on Exception catch (_) {
      // Ignore picker errors — user may have cancelled
    }
    if (picked.isEmpty) return;

    final files = await Future.wait(picked.map((e) => e.file));
    if (!mounted) return;
    // Fixes a bug: this used to mutate accommodation.images.images directly
    // outside of setState, so newly added photos didn't show up until some
    // unrelated rebuild happened to fire.
    setState(() {
      accommodation.images.images.addAll(files);
      hasChanges.value = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final detailsToUpdate = AccommodationDetails(
      numberOfBeds: int.parse(_numBedsController.text),
      bathub: _accommodationDetails['Bathtub']!,
      balcony: _accommodationDetails['Balcony']!,
      privateBathroom: _accommodationDetails['Private Bathroom']!,
      ac: _accommodationDetails['Air Conditioning']!,
      terrace: _accommodationDetails['Terrace']!,
      kitchen: _accommodationDetails['Kitchen']!,
      privatePool: _accommodationDetails['Private Pool']!,
      coffeeMachine: _accommodationDetails['Coffee Machine']!,
      view: _accommodationDetails['View']!,
      seaView: _accommodationDetails['Sea View']!,
      washingMachine: _accommodationDetails['Washing Machine']!,
      spaTub: _accommodationDetails['Spa Tub']!,
      soundProof: _accommodationDetails['Soundproof']!,
      breakfast: _accommodationDetails['Breakfast']!,
    );
    final patch = AccommodationPATCH(
      id: accommodation.id,
      status: accommodation.status,
      images: accommodation.images,
      // Fixes a bug: this used to send _nameController.text, but the Name
      // field was never wired to that controller (it wrote straight to
      // accommodation.name instead), so edits to the name were silently
      // dropped on save.
      name: accommodation.name,
      pricePerNight: double.parse(_priceController.text),
      description: _descriptionController.text,
      accommodationDetails: detailsToUpdate,
      typeOfAccommodation: accommodation.typeOfAccommodation,
    );

    final result = await Provider.of<AccommodationProvider>(context, listen: false)
        .updateAccommodation(patch);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result) {
      hasChanges.value = false;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Saved'),
          content: const Text('Accommodation updated successfully.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
          ],
        ),
      );
    } else {
      // Fixes a bug: failures used to call showAboutDialog (Flutter's
      // built-in "About this app" dialog) instead of an actual error dialog.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Something went wrong'),
          content: const Text('Failed to update accommodation. Please try again.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                    validator: (v) => (v == null || v.isEmpty) ? 'Please enter a name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price per night', prefixText: '\$ '),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => hasChanges.value = true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter the price per night';
                      if (double.tryParse(value) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    onChanged: (_) => hasChanges.value = true,
                    validator: (v) => (v == null || v.isEmpty) ? 'Please enter a description' : null,
                  ),
                  const SizedBox(height: 12),
                  // The address can't be changed from this screen -- the
                  // update endpoint doesn't accept a location, so an
                  // editable field here would silently do nothing on save.
                  // Shown read-only instead of the dead, never-wired field
                  // that used to sit here.
                  Row(
                    children: [
                      Icon(PhosphorIcons.mapPin(), size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(accommodation.location.address, style: textTheme.bodySmall),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppColors.radiusMd),
                    child: SizedBox(
                      height: 160,
                      child: maps.GoogleMap(
                        initialCameraPosition: maps.CameraPosition(
                          target: maps.LatLng(
                              accommodation.location.latitude, accommodation.location.longitude),
                          zoom: 14,
                        ),
                        markers: {
                          maps.Marker(
                            markerId: maps.MarkerId(accommodation.name),
                            position: maps.LatLng(
                                accommodation.location.latitude, accommodation.location.longitude),
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
                title: 'Photos',
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: accommodation.images.images.length + 1,
                    itemBuilder: (context, index) {
                      if (index == accommodation.images.images.length) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(AppColors.radiusMd),
                          onTap: _addImages,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(AppColors.radiusMd),
                            ),
                            alignment: Alignment.center,
                            child: Icon(PhosphorIcons.plus(), color: AppColors.textSecondary, size: 22),
                          ),
                        );
                      }
                      final isCover = index == 0;
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppColors.radiusMd),
                              child: Image.file(accommodation.images.images[index]!, fit: BoxFit.cover),
                            ),
                          ),
                          if (isCover)
                            Positioned(
                              left: 4,
                              bottom: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.bg.withValues(alpha: 0.82),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('Cover', style: TextStyle(fontSize: 10)),
                              ),
                            ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  accommodation.images.images.removeAt(index);
                                  hasChanges.value = true;
                                });
                              },
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: AppColors.bg.withValues(alpha: 0.85),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(PhosphorIcons.x(), size: 12, color: AppColors.text),
                              ),
                            ),
                          ),
                          if (!isCover)
                            Positioned(
                              left: 4,
                              bottom: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    accommodation.images.images.insert(
                                        0, accommodation.images.images.removeAt(index));
                                    hasChanges.value = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.bg.withValues(alpha: 0.82),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Make cover', style: TextStyle(fontSize: 9.5)),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Card(
                title: 'Amenities',
                children: [
                  TextFormField(
                    controller: _numBedsController,
                    decoration: const InputDecoration(labelText: 'Number of beds'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => hasChanges.value = true,
                    validator: (v) => (v == null || v.isEmpty) ? 'Please enter the number of beds' : null,
                  ),
                  const SizedBox(height: 16),
                  for (final group in _amenityGroups.entries) ...[
                    Text(group.key.toUpperCase(), style: textTheme.labelSmall),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: [
                        for (final key in group.value)
                          _AmenityToggle(
                            label: key,
                            selected: _accommodationDetails[key] ?? false,
                            onTap: () => setState(() {
                              _accommodationDetails[key] = !(_accommodationDetails[key] ?? false);
                              hasChanges.value = true;
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<bool>(
                valueListenable: hasChanges,
                builder: (context, value, child) {
                  return OutlinedButton(
                    onPressed: (value && !_isSaving) ? _save : null,
                    child: _isSaving
                        ? const SizedBox(
                            height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save changes'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomPartnerBottomNavigationBar(currentIndex: 0),
    );
  }
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

  const _AmenityToggle({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentTint : null,
          border: Border.all(color: selected ? AppColors.accent : AppColors.border),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(PhosphorIcons.check(), size: 13, color: AppColors.accentText),
              const SizedBox(width: 7),
            ],
            Text(label,
                style: TextStyle(fontSize: 13, color: selected ? AppColors.accentText : AppColors.text)),
          ],
        ),
      ),
    );
  }
}
