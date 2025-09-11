String getFormattedDate(int secondsSinceEpoch) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
    secondsSinceEpoch * 1000,
  );
  return "${getRelativeDate(dateTime)}, ${dateTime.day}/${dateTime.month}/${dateTime.year} ${hourTo12(dateTime.hour).toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour < 12 ? "AM" : "PM"}";
}

int hourTo12(int hour) {
  if (hour > 12) {
    return hour - 12;
  } else {
    return hour;
  }
}

String getRelativeDate(DateTime articleTime) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(articleTime);
  if (difference.inDays > 0) {
    if (difference.inDays < 30) {
      if (difference.inDays < 2) {
        return difference.inDays == 0 ? "Today" : "Yesterday";
      }
      return "${difference.inDays} Days";
    } else if (difference.inDays < 365) {
      int months = (difference.inDays / 30).floor();
      return "$months ${months == 1 ? "Month" : "Months"}";
    } else {
      int years = (difference.inDays / 365).floor();
      return "$years ${years == 1 ? "Year" : "Years"}";
    }
  } else if (difference.inHours > 0) {
    return "${difference.inHours} ${difference.inHours == 1 ? "Hour" : "Hours"}";
  } else if (difference.inMinutes > 0) {
    return "${difference.inMinutes} ${difference.inMinutes == 1 ? "Minute" : "Minutes"}";
  }
  return "Just Now";
}

int getDifferenceInDays(int secondsSinceEpoch) {
  DateTime articleTime = DateTime.fromMillisecondsSinceEpoch(
    secondsSinceEpoch * 1000,
  );
  DateTime now = DateTime.now();
  Duration difference = now.difference(articleTime);
  return difference.inDays;
}
