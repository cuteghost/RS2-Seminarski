import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/accomodation_model.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/customer_screens/booking_screen.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class AccommodationDetailsScreen extends StatefulWidget {
  final AccommodationGET accommodation;

  const AccommodationDetailsScreen({super.key, required this.accommodation});

  @override
  AccommodationDetailsScreenState createState() =>
      AccommodationDetailsScreenState();
}

class AccommodationDetailsScreenState
    extends State<AccommodationDetailsScreen> {
  late AccommodationGET accommodation;
  final PageController _galleryController = PageController();
  int _galleryIndex = 0;

  @override
  void initState() {
    super.initState();
    accommodation = widget.accommodation;
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  // (icon, label) pairs for every amenity flag the property actually has set.
  // Only shown when true -- no point listing fourteen "off" amenities.
  List<(IconData, String)> get _activeAmenities {
    final d = accommodation.accommodationDetails;
    return [
      if (d.privateBathroom) (PhosphorIcons.shower(), 'Private bathroom'),
      if (d.bathub) (PhosphorIcons.bathtub(), 'Bathtub'),
      if (d.terrace) (PhosphorIcons.umbrella(), 'Terrace'),
      if (d.balcony) (PhosphorIcons.doorOpen(), 'Balcony'),
      if (d.privatePool) (PhosphorIcons.swimmingPool(), 'Private pool'),
      if (d.seaView || d.view) (PhosphorIcons.mountains(), 'View'),
      if (d.ac) (PhosphorIcons.snowflake(), 'A/C'),
      if (d.kitchen) (PhosphorIcons.cookingPot(), 'Kitchen'),
      if (d.coffeeMachine) (PhosphorIcons.coffee(), 'Coffee machine'),
      if (d.washingMachine) (PhosphorIcons.tShirt(), 'Washing machine'),
      if (d.soundProof) (PhosphorIcons.speakerSimpleX(), 'Soundproof'),
      if (d.breakfast) (PhosphorIcons.forkKnife(), 'Breakfast'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final images = accommodation.images.images;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 300,
                        child: images.isEmpty
                            ? Container(
                                color: AppColors.surface,
                                alignment: Alignment.center,
                                child: Icon(PhosphorIcons.image(),
                                    size: 36, color: AppColors.textTertiary),
                              )
                            : PageView.builder(
                                controller: _galleryController,
                                itemCount: images.length,
                                onPageChanged: (i) =>
                                    setState(() => _galleryIndex = i),
                                itemBuilder: (context, index) {
                                  return Image.file(
                                    images[index]!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  );
                                },
                              ),
                      ),
                      Positioned(
                        top: 18,
                        left: 16,
                        child: _RoundIconButton(
                          icon: PhosphorIcons.arrowLeft(),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Positioned(
                        top: 18,
                        right: 16,
                        child: _RoundIconButton(
                          icon: PhosphorIcons.heart(),
                          onPressed: () {},
                        ),
                      ),
                      if (images.isNotEmpty)
                        Positioned(
                          bottom: 14,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.bg.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('${_galleryIndex + 1} / ${images.length}',
                                style: const TextStyle(fontSize: 11.5)),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(accommodation.name,
                                  style: textTheme.headlineMedium
                                      ?.copyWith(fontSize: 24)),
                            ),
                            if (accommodation.reviewScore > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(PhosphorIcons.star(PhosphorIconsStyle.fill),
                                        size: 13, color: AppColors.accent),
                                    const SizedBox(width: 5),
                                    Text(
                                        accommodation.reviewScore
                                            .toStringAsFixed(1),
                                        style: textTheme.bodyMedium),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(accommodation.location.address,
                            style: textTheme.bodySmall),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _AmenityChip(
                              icon: PhosphorIcons.bed(),
                              label:
                                  '${accommodation.accommodationDetails.numberOfBeds} beds',
                            ),
                            for (final (icon, label) in _activeAmenities)
                              _AmenityChip(icon: icon, label: label),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          accommodation.description,
                          style: textTheme.bodyLarge
                              ?.copyWith(color: AppColors.text.withValues(alpha: 0.85)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 18, bottom: 18),
                          child: Divider(color: AppColors.divider, height: 1),
                        ),
                        Row(
                          children: [
                            Icon(PhosphorIcons.clock(),
                                size: 19, color: AppColors.accent),
                            const SizedBox(width: 12),
                            const Text('Check-in 12:00 – 22:00'),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text:
                                '\$${accommodation.pricePerNight.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: ' / night',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookingScreen(accommodation: accommodation),
                        ),
                      );
                    },
                    child: const Text('Reserve'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg.withValues(alpha: 0.75),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 17, color: AppColors.text),
        ),
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AmenityChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.text)),
        ],
      ),
    );
  }
}
