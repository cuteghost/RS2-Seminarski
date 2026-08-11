import 'package:flutter/material.dart';

/// Drop-in replacement for the abandoned `icon_badge` package's `IconBadge`.
///
/// Wraps Material 3's built-in [Badge] and keeps the same parameter semantics
/// the old call sites relied on, so no behaviour changes at the usage points.
class CountBadge extends StatelessWidget {
  const CountBadge({
    super.key,
    required this.icon,
    required this.itemCount,
    this.badgeColor,
    this.itemColor,
    this.maxCount = 99,
    this.hideZero = false,
  });

  /// The widget the badge is drawn on top of.
  final Widget icon;

  /// The number rendered inside the badge.
  final int itemCount;

  /// Background colour of the badge.
  final Color? badgeColor;

  /// Colour of the number inside the badge.
  final Color? itemColor;

  /// Counts above this are rendered as `<maxCount>+`.
  final int maxCount;

  /// When true, the badge is hidden entirely if [itemCount] is zero.
  final bool hideZero;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: !hideZero || itemCount != 0,
      backgroundColor: badgeColor,
      textColor: itemColor,
      label: Text(itemCount > maxCount ? '$maxCount+' : '$itemCount'),
      child: icon,
    );
  }
}
