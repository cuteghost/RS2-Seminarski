import 'dart:io';
import 'package:ebooking/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class SuggestionContainer extends StatelessWidget {
  final File? image;
  final String propertyName;
  final double pricePerNight;
  final double reviewScore;
  final String address;
  final VoidCallback? onTap;

  const SuggestionContainer({
    super.key,
    required this.image,
    required this.propertyName,
    required this.pricePerNight,
    required this.reviewScore,
    required this.address,
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
              child: image != null
                  ? Image.file(image!, width: 76, height: 76, fit: BoxFit.cover)
                  : Container(
                      width: 76,
                      height: 76,
                      color: AppColors.accentTint,
                      alignment: Alignment.center,
                      child: Icon(PhosphorIcons.image(),
                          size: 20, color: AppColors.textTertiary),
                    ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(propertyName, style: textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(address, style: textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (reviewScore > 0) ...[
                        Icon(PhosphorIcons.star(PhosphorIconsStyle.fill),
                            size: 12, color: AppColors.accent),
                        const SizedBox(width: 5),
                        Text(reviewScore.toStringAsFixed(1), style: textTheme.bodySmall),
                        const SizedBox(width: 10),
                      ],
                      Text('\$${pricePerNight.toStringAsFixed(0)} / night',
                          style: textTheme.bodyMedium),
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
