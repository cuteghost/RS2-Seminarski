import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/config/config.dart';
import 'package:ebooking/services/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class RemoteImage extends StatelessWidget {
  final String? path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const RemoteImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  static Future<Map<String, String>> _headers() async {
    final token = await SecureStorage().getToken();
    return token == null
        ? <String, String>{}
        : <String, String>{'Authorization': 'Bearer $token'};
  }

  static Future<void> evict(String path) async {
    if (path.isEmpty) return;
    await NetworkImage(
      '${AppConfig.baseUrl}$path',
      headers: await _headers(),
    ).evict();
  }

  @override
  Widget build(BuildContext context) {
    final relative = path;
    if (relative == null || relative.isEmpty) return _placeholder();

    return FutureBuilder<Map<String, String>>(
      future: _headers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _placeholder();
        return Image.network(
          '${AppConfig.baseUrl}$relative',
          headers: snapshot.data,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceRaised,
      child: Center(
        child: Icon(
          PhosphorIcons.image(),
          size: 20,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
