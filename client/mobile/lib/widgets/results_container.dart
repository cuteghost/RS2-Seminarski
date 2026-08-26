import 'dart:io';

import 'package:ebooking/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// A single search-result card: full-width photo, name + rating, address,
/// sleeps count, and a labelled total/per-night price line.
///
/// Unreviewed properties (reviewScore == 0) show "No reviews yet" instead of
/// a "0.0" badge, which used to read as a bad score rather than an absent one.
class SearchResultContainer extends StatelessWidget {
  final File? image;
  final String propertyName;
  final double pricePerNight;
  final double reviewScore;
  final String totalPrice;
  final String address;
  final int? sleeps;
  final VoidCallback? onTap;

  const SearchResultContainer({
    super.key,
    required this.image,
    required this.propertyName,
    required this.pricePerNight,
    required this.reviewScore,
    required this.totalPrice,
    required this.address,
    this.sleeps,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppColors.radiusMd),
                child: image != null
                    ? Image.file(
                        image!,
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 190,
                        width: double.infinity,
                        color: AppColors.surface,
                        alignment: Alignment.center,
                        child: Icon(PhosphorIcons.image(),
                            color: AppColors.textTertiary, size: 28),
                      ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.bg.withValues(alpha: 0.82),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(PhosphorIcons.heart(), size: 15, color: AppColors.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(propertyName, style: textTheme.titleMedium),
              ),
              const SizedBox(width: 8),
              reviewScore > 0
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(PhosphorIcons.star(PhosphorIconsStyle.fill),
                            size: 12, color: AppColors.accent),
                        const SizedBox(width: 5),
                        Text(reviewScore.toStringAsFixed(1),
                            style: textTheme.bodyMedium),
                      ],
                    )
                  : Text('No reviews yet', style: textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 3),
          Text(address, style: textTheme.bodySmall),
          if (sleeps != null) ...[
            const SizedBox(height: 2),
            Text('Sleeps $sleeps',
                style: textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
          ],
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: totalPrice,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                TextSpan(
                  text: ' total · \$${pricePerNight.toStringAsFixed(0)} / night',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
