import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/widgets/remote_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:ebooking/utils/rating.dart';

/// A partner's own listing card -- thumbnail, live/paused status dot,
/// price + reviews, and (when paused) a Publish shortcut. Distinct from
/// SearchResultContainer: partners need status and earnings-relevant info,
/// not the customer-facing rating badge treatment.
class AccommodationContainer extends StatelessWidget {
  final String? imageUrl;
  final String propertyName;
  final String address;
  final int reviews;
  final bool isAvailable;
  final double reviewScore;
  final String price;
  final int numberOfBeds;
  final VoidCallback? onTap;
  final VoidCallback? onPublish;

  const AccommodationContainer({
    super.key,
    required this.imageUrl,
    required this.propertyName,
    required this.address,
    required this.reviews,
    required this.isAvailable,
    required this.reviewScore,
    required this.price,
    required this.numberOfBeds,
    this.onTap,
    this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
        ),
        padding: const EdgeInsets.all(13),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          propertyName,
                          style: textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isAvailable
                                  ? AppColors.success
                                  : AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isAvailable ? 'Live' : 'Paused',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      address,
                      style: textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 3),
                  Text(
                    '\$$price / night · Sleeps $numberOfBeds',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 3),
                  reviews > 0
                      ? Row(
                          children: [
                            Icon(
                              PhosphorIcons.star(PhosphorIconsStyle.fill),
                              size: 12,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${formatRating(reviewScore)} · $reviews reviews',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        )
                      : Text('No reviews yet', style: textTheme.bodySmall),
                  if (!isAvailable && onPublish != null) ...[
                    const SizedBox(height: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: onPublish,
                      child: const Text('Publish'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
