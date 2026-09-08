import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/config/config.dart' as config;

class AuthorizedImage extends StatelessWidget {
  final String path;
  final String? token;
  final double width;
  final double height;
  final BoxFit fit;
  final double iconSize;

  const AuthorizedImage({
    super.key,
    required this.path,
    required this.token,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty || token == null || token!.isEmpty) {
      return _placeholder(PhosphorIcons.image());
    }

    return Image.network(
      path.startsWith('http') ? path : '${config.AppConfig.baseUrl}$path',
      headers: {'Authorization': 'Bearer $token'},
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _placeholder(PhosphorIcons.image()),
      errorBuilder: (_, __, ___) => _placeholder(PhosphorIcons.imageBroken()),
    );
  }

  Widget _placeholder(IconData icon) {
    return Container(
      width: width,
      height: height,
      color: AppColors.neutral900,
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: AppColors.textTertiary),
    );
  }
}
