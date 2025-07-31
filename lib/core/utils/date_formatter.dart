import 'package:intl/intl.dart';

class DateFormatter {
  // Common date formats
  static final DateFormat _dayMonthYear = DateFormat('dd/MM/yyyy');
  static final DateFormat _monthDayYear = DateFormat('MM/dd/yyyy');
  static final DateFormat _yearMonthDay = DateFormat('yyyy-MM-dd');
  static final DateFormat _fullDate = DateFormat('EEEE, MMMM d, yyyy');
  static final DateFormat _shortDate = DateFormat('MMM d, yyyy');
  static final DateFormat _timeOnly = DateFormat('HH:mm');
  static final DateFormat _timeWithSeconds = DateFormat('HH:mm:ss');
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _fullDateTime = DateFormat('EEEE, MMMM d, yyyy HH:mm');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _dayMonth = DateFormat('dd MMM');

  // Format date to different formats
  static String formatToDayMonthYear(DateTime date) {
    return _dayMonthYear.format(date);
  }

  static String formatToMonthDayYear(DateTime date) {
    return _monthDayYear.format(date);
  }

  static String formatToYearMonthDay(DateTime date) {
    return _yearMonthDay.format(date);
  }

  static String formatToFullDate(DateTime date) {
    return _fullDate.format(date);
  }

  static String formatToShortDate(DateTime date) {
    return _shortDate.format(date);
  }

  static String formatToTimeOnly(DateTime date) {
    return _timeOnly.format(date);
  }

  static String formatToTimeWithSeconds(DateTime date) {
    return _timeWithSeconds.format(date);
  }

  static String formatToDateTime(DateTime date) {
    return _dateTime.format(date);
  }

  static String formatToFullDateTime(DateTime date) {
    return _fullDateTime.format(date);
  }

  static String formatToMonthYear(DateTime date) {
    return _monthYear.format(date);
  }

  static String formatToDayMonth(DateTime date) {
    return _dayMonth.format(date);
  }

  // Relative time formatting
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Format fixture date/time
  static String formatFixtureDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final fixtureDate = DateTime(date.year, date.month, date.day);

    if (fixtureDate == today) {
      return 'Today ${formatToTimeOnly(date)}';
    } else if (fixtureDate == tomorrow) {
      return 'Tomorrow ${formatToTimeOnly(date)}';
    } else if (fixtureDate == yesterday) {
      return 'Yesterday ${formatToTimeOnly(date)}';
    } else if (date.year == now.year) {
      return '${formatToDayMonth(date)} ${formatToTimeOnly(date)}';
    } else {
      return '${formatToShortDate(date)} ${formatToTimeOnly(date)}';
    }
  }

  // Get week day name
  static String getWeekDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  // Get month name
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
           date.month == tomorrow.month &&
           date.day == tomorrow.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }

  // Parse date from string
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Format duration
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  // Get age from birth date
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }
}