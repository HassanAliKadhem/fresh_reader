import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class ArticleImage extends StatelessWidget {
  const ArticleImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.onError,
    this.isViewer = false,
    this.fit = BoxFit.fitWidth,
  });
  final String imageUrl;
  final double? width;
  final double? height;
  final Widget Function(String error)? onError;
  final bool isViewer;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      cache: true,
      cacheHeight: height?.round(),
      cacheWidth: width?.round(),
      cacheMaxAge: Duration(days: 7),
      clearMemoryCacheIfFailed: true,
      clearMemoryCacheWhenDispose: true,
      enableSlideOutPage: true,
      mode: isViewer ? ExtendedImageMode.gesture : ExtendedImageMode.none,
      initGestureConfigHandler: (state) {
        if (isViewer) {
          return GestureConfig(
            minScale: 0.9,
            animationMinScale: 0.7,
            maxScale: 3.0,
            animationMaxScale: 3.5,
            speed: 1.0,
            inertialSpeed: 100.0,
            initialScale: 1.0,
            inPageView: false,
            initialAlignment: InitialAlignment.center,
          );
        }
        return GestureConfig();
      },
      // shape: boxShape,
      //cancelToken: cancellationToken,
      handleLoadingProgress: true,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return CircularProgressIndicator.adaptive(
              constraints: BoxConstraints(maxWidth: 16.0, maxHeight: 16.0),
              year2023: false,
            );
          case LoadState.failed:
            if (onError != null) {
              return onError!(state.lastException.toString());
            }
            return Placeholder(child: Text(state.lastException.toString()));
          case LoadState.completed:
            return null;
        }
      },
    );
  }
}
