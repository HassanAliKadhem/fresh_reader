import 'package:flutter/widgets.dart';

import '../api/database.dart';

ScreenSize screenSizeOf(BuildContext context) {
  if (MediaQuery.sizeOf(context).width > 840) {
    return ScreenSize.big;
  } else if (MediaQuery.sizeOf(context).width > 640) {
    return ScreenSize.medium;
  } else {
    return ScreenSize.small;
  }
}
