import 'package:flutter/widgets.dart';

enum ScreenSize { big, medium, small }

ScreenSize screenSizeOf(BuildContext context) {
  if (MediaQuery.sizeOf(context).width > 900) {
    return ScreenSize.big;
  } else if (MediaQuery.sizeOf(context).width > 700) {
    return ScreenSize.medium;
  } else {
    return ScreenSize.small;
  }
}
