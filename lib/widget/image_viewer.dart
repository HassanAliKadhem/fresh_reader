import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'blur_bar.dart';

class ImageViewer extends StatefulWidget {
  const ImageViewer(
      {super.key, required this.image, this.text = "", required this.url});
  final Widget image;
  final String text;
  final String url;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  // https://stackoverflow.com/questions/54536275/flutter-how-to-implement-rotate-and-pan-move-gesture-for-any-container
  Offset _offset = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;
  Offset _sessionOffset = Offset.zero;

  double _scale = 1.0;
  double _initialScale = 1.0;

  final Duration _duration = const Duration(milliseconds: 300);
  Duration _currentDuration = const Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
          ),
          FittedBox(
            child: GestureDetector(
              onScaleStart: (details) {
                _currentDuration = const Duration(milliseconds: 100);
                _initialFocalPoint = details.focalPoint;
                _initialScale = _scale;
              },
              onScaleUpdate: (details) {
                setState(() {
                  _sessionOffset = details.focalPoint - _initialFocalPoint;
                  _scale = _initialScale * details.scale;
                });
              },
              onScaleEnd: (details) {
                _currentDuration = _duration;
                setState(() {
                  _offset += _sessionOffset;
                  if (_offset.distance >
                      MediaQuery.sizeOf(context).shortestSide / 2) {
                    Navigator.pop(context);
                  }
                  _sessionOffset = Offset.zero;
                  _scale = 1.0;
                  _offset = Offset.zero;
                });
              },
              onDoubleTapDown: (details) {
                setState(() {
                  if (_scale != 1.0) {
                    _scale = 1.0;
                  } else {
                    _scale = 2.0;
                  }
                });
              },
              child: TweenAnimationBuilder(
                  tween: Tween<Offset>(
                      begin: Offset.zero, end: _offset + _sessionOffset),
                  duration: _currentDuration,
                  curve: Curves.easeOut,
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: _initialScale, end: _scale),
                    duration: _currentDuration,
                    curve: Curves.easeOut,
                    child: widget.image,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: widget.image,
                      );
                    },
                  ),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: value,
                      child: child,
                    );
                  }),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BlurBar(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(widget.text),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Share.shareUri(Uri.parse(widget.url));
                    },
                    icon: const Icon(Icons.share),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
