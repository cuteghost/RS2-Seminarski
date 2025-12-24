import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;

  const AssetThumbnail({Key? key, required this.asset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(
        ThumbnailSize(100, 100),
        format: ThumbnailFormat.jpeg,
        quality: 100,
      ),
      builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          return Icon(Icons.error);
        }
      },
    );
  }
}