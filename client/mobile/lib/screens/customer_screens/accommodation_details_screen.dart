import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/accommodation_model.dart';
import 'package:ebooking/models/feedback_model.dart';
import 'package:ebooking/providers/feedback_provider.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/utils/rating.dart';
import 'package:ebooking/widgets/amenity_icons.dart';
import 'package:ebooking/widgets/location_map.dart';
import 'package:ebooking/widgets/remote_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebooking/screens/customer_screens/booking_screen.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class AccommodationDetailsScreen extends StatefulWidget {
  final AccommodationGET accommodation;
  final DateTime? checkIn;
  final DateTime? checkOut;

  const AccommodationDetailsScreen({
    super.key,
    required this.accommodation,
    this.checkIn,
    this.checkOut,
  });

  @override
  AccommodationDetailsScreenState createState() =>
      AccommodationDetailsScreenState();
}

class AccommodationDetailsScreenState
    extends State<AccommodationDetailsScreen> {
  late AccommodationGET accommodation;
  final PageController _galleryController = PageController();
  final ScrollController _pageScrollController = ScrollController();
  int _galleryIndex = 0;

  @override
  void initState() {
    super.initState();
    accommodation = widget.accommodation;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReviews());
    _pageScrollController.addListener(_onScroll);
  }

  Future<void> _loadReviews() async {
    try {
      await Provider.of<FeedbackProvider>(
        context,
        listen: false,
      ).loadReviews(accommodation.id);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _onScroll() {
    if (!_pageScrollController.hasClients) return;
    if (_pageScrollController.position.pixels <
        _pageScrollController.position.maxScrollExtent - 200) {
      return;
    }
    final feedback = Provider.of<FeedbackProvider>(context, listen: false);
    if (feedback.isLoadingMoreReviews(accommodation.id) ||
        !feedback.hasMoreReviews(accommodation.id)) {
      return;
    }
    feedback.loadMoreReviews(accommodation.id).catchError((Object error) {
      if (!mounted || error is! ApiException) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    });
  }

  @override
  void dispose() {
    _galleryController.dispose();
    _pageScrollController.removeListener(_onScroll);
    _pageScrollController.dispose();
    super.dispose();
  }

  List<(IconData, String)> get _activeAmenities {
    final amenities = [...accommodation.accommodationDetails.amenities]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return amenities
        .map((amenity) => (amenityIcon(amenity.code), amenity.name))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final images = accommodation.imageUrls;
    final topInset = MediaQuery.of(context).padding.top;
    final feedback = Provider.of<FeedbackProvider>(context);
    final reviews = feedback.reviewsFor(accommodation.id);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _pageScrollController,
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
                                child: Icon(
                                  PhosphorIcons.image(),
                                  size: 36,
                                  color: AppColors.textTertiary,
                                ),
                              )
                            : PageView.builder(
                                controller: _galleryController,
                                itemCount: images.length,
                                onPageChanged: (i) =>
                                    setState(() => _galleryIndex = i),
                                itemBuilder: (context, index) {
                                  return RemoteImage(
                                    path: images[index],
                                    width: double.infinity,
                                  );
                                },
                              ),
                      ),
                      Positioned(
                        top: topInset + 18,
                        left: 16,
                        child: _RoundIconButton(
                          icon: PhosphorIcons.arrowLeft(),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      if (images.isNotEmpty)
                        Positioned(
                          bottom: 14,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bg.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${_galleryIndex + 1} / ${images.length}',
                              style: const TextStyle(fontSize: 11.5),
                            ),
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
                              child: Text(
                                accommodation.name,
                                style: textTheme.headlineMedium?.copyWith(
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            if (accommodation.reviewScore > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      PhosphorIcons.star(
                                        PhosphorIconsStyle.fill,
                                      ),
                                      size: 13,
                                      color: AppColors.accent,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      formatRating(accommodation.reviewScore),
                                      style: textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          accommodation.location.address,
                          style: textTheme.bodySmall,
                        ),
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
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.text.withValues(alpha: 0.85),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 18, bottom: 18),
                          child: Divider(color: AppColors.divider, height: 1),
                        ),
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.clock(),
                              size: 19,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 12),
                            const Text('Check-in 12:00 – 22:00'),
                          ],
                        ),
                        if (reviews == null || reviews.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 18, bottom: 18),
                            child: Divider(color: AppColors.divider, height: 1),
                          ),
                          Text('Guest reviews', style: textTheme.titleMedium),
                          const SizedBox(height: 10),
                          if (reviews == null)
                            Text(
                              'Loading reviews...',
                              style: textTheme.bodySmall,
                            )
                          else ...[
                            for (final review in reviews)
                              _ReviewCard(review: review),
                            if (feedback.isLoadingMoreReviews(accommodation.id))
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ],
                        Padding(
                          padding: const EdgeInsets.only(top: 18, bottom: 18),
                          child: Divider(color: AppColors.divider, height: 1),
                        ),
                        Text('Location', style: textTheme.titleMedium),
                        const SizedBox(height: 10),
                        LocationMap(
                          location: accommodation.location,
                          markerTitle: accommodation.name,
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
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
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
                          builder: (context) => BookingScreen(
                            accommodation: accommodation,
                            checkIn: widget.checkIn,
                            checkOut: widget.checkOut,
                          ),
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

class _ReviewCard extends StatelessWidget {
  final AccommodationReview review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.customerDisplayName.isEmpty
                      ? 'Guest'
                      : review.customerDisplayName,
                  style: textTheme.bodyMedium,
                ),
              ),
              Icon(
                PhosphorIcons.star(PhosphorIconsStyle.fill),
                size: 12,
                color: AppColors.accent,
              ),
              const SizedBox(width: 5),
              Text(
                formatRating(review.rating.toDouble()),
                style: textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review.comment,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.text.withValues(alpha: 0.85),
            ),
          ),
          if (review.wouldRecommend) ...[
            const SizedBox(height: 6),
            Text(
              'Would recommend',
              style: textTheme.bodySmall?.copyWith(color: AppColors.accentText),
            ),
          ],
        ],
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
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.text),
          ),
        ],
      ),
    );
  }
}
