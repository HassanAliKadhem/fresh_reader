import 'dart:ui';

import 'package:flutter/material.dart';

class BlurBar extends StatelessWidget {
  const BlurBar({super.key, this.child, this.hasBorder = true});
  final Widget? child;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).canvasColor.withAlpha(hasBorder ? 128 : 80),
            border:
                !hasBorder
                    ? null
                    : Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor.withAlpha(32),
                      ),
                      top: BorderSide(
                        color: Theme.of(context).dividerColor.withAlpha(32),
                      ),
                    ),
          ),
          child: child,
        ),
      ),
    );
  }
}
