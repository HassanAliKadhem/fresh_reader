import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ArticleImage extends StatelessWidget {
  const ArticleImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
  });
  final String imageUrl;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fit: BoxFit.fitWidth,
      imageUrl: imageUrl,
      width: width,
      height: height,
      progressIndicatorBuilder:
          (context, url, progress) => SizedBox(
            width: 16.0,
            height: 16.0,
            child: CircularProgressIndicator.adaptive(
              year2023: false,
              value: progress.progress,
            ),
          ),
      errorWidget: (context, url, error) {
        return Placeholder(child: Text(error.toString().split(",").first));
      },
    );
  }
}
