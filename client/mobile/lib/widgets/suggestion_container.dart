import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/widgets/remote_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:ebooking/utils/rating.dart';

class SuggestionContainer extends StatelessWidget {
  final String? imageUrl;
  final String propertyName;
  final double pricePerNight;
  final double reviewScore;
  final String address;

  /// Set only where the distance is the point of the list. The Near you
  /// screen leads with it; the suggestions list leaves it out.
  final double? distanceKm;
  final VoidCallback? onTap;

  const SuggestionContainer({
    super.key,
    required this.imageUrl,
    required this.propertyName,
    required this.pricePerNight,
    required this.reviewScore,
    required this.address,
    this.distanceKm,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: RemoteImage(path: imageUrl, width: 76, height: 76),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(propertyName, style: textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(
                    distanceKm == null
                        ? address
                        : '${distanceKm!.toStringAsFixed(1)} km away · $address',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (reviewScore > 0) ...[
                        Icon(
                          PhosphorIcons.star(PhosphorIconsStyle.fill),
                          size: 12,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          formatRating(reviewScore),
                          style: textTheme.bodySmall,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        '\$${pricePerNight.toStringAsFixed(0)} / night',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
