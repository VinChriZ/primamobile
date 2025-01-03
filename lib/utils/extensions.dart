import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1).toLowerCase()}";

  String toTitleCase() {
    List<String> stringList = trim().split(' ');
    stringList = stringList.map((e) => e.capitalize()).toList();
    return stringList.join(' ');
  }
}

extension DoubleExtension on double {
  String toCurrencyString() {
    NumberFormat formatter = NumberFormat.decimalPattern();
    return formatter.format(this);
  }
}

extension DateTimeExtension on DateTime {
  /// dateTimeString must be in this order: day, month, year, hour, minute, second
  static DateTime fromString({
    required String dateTimeString,
    String dateTimeDelimiter = ' ',
    String dateDelimiter = '/',
    String timeDelimiter = ':',
    bool includeTime = true,
  }) {
    try {
      List<String> dateTimeParts = dateTimeString.split(dateTimeDelimiter);
      if (dateTimeParts.isEmpty || dateTimeParts.length > 2) {
        throw const FormatException('Invalid date-time format');
      }

      List<String> dateParts = dateTimeParts[0].split(dateDelimiter);
      if (dateParts.length != 3) {
        throw const FormatException('Invalid date format');
      }

      int day = int.tryParse(dateParts[0]) ?? 1;
      int month = int.tryParse(dateParts[1]) ?? 1;
      int year = int.tryParse(dateParts[2]) ?? 1945;

      if (includeTime) {
        if (dateTimeParts.length != 2) {
          throw const FormatException('Invalid date-time format');
        }

        List<String> timeParts = dateTimeParts[1].split(timeDelimiter);
        if (timeParts.length != 2) {
          throw const FormatException('Invalid time format');
        }

        int hour = int.tryParse(timeParts[0]) ?? 0;
        int minute = int.tryParse(timeParts[1]) ?? 0;

        return DateTime(year, month, day, hour, minute);
      } else {
        return DateTime(year, month, day);
      }
    } catch (e) {
      throw FormatException('Invalid date-time format: $e');
    }
  }

  String toShortString({String? customFormat}) {
    DateFormat formatter = DateFormat(customFormat ?? 'dd/MM/yyyy');
    return formatter.format(this);
  }

  String toLongString({String? customFormat}) {
    DateFormat formatter = DateFormat(customFormat ?? 'dd/MM/yyyy HH:mm');
    return formatter.format(this);
  }

  String toTimeString({String? format = 'HH:mm'}) {
    DateFormat formatter = DateFormat(format);
    return formatter.format(this);
  }

  String toDayString({String? customFormat}) {
    DateFormat formatter = DateFormat(customFormat ?? 'EEEE');
    return formatter.format(this);
  }
}

extension TimeOfDayExtension on TimeOfDay {
  static TimeOfDay fromString({required String timeOfDayString, String delimiter = ':'}) {
    int hour = int.tryParse(timeOfDayString.split(delimiter)[0]) ?? 0;
    int minute = int.tryParse(timeOfDayString.split(delimiter)[1]) ?? 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  String toShortString() {
    String hourString = hour.toString().padLeft(2, '0');
    String minuteString = minute.toString().padLeft(2, '0');

    return '$hourString:$minuteString';
  }
}

extension DateTimeRangeExtension on DateTimeRange {
  String toShortString({String format = 'dd/MM/yyyy'}) {
    DateFormat formatter = DateFormat(format);
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }
}

extension Uint8ListExtension on Uint8List {
  static Uint8List fromString(String value) {
    Uint8List uint8List = Uint8List(value.length);
    for (var i = 0; i < value.length; i++) {
      uint8List[i] = value.codeUnitAt(i);
    }

    return uint8List;
  }
}

extension EmailValidationExtension on String {
  bool isValid() {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(this);
  }
}

extension PermissionStatusExtension on PermissionStatus {
  String toReadableString() {
    String verbose = "Unknown";

    switch (this) {
      case PermissionStatus.granted:
        verbose = 'Allowed';
        break;
      case PermissionStatus.limited:
        verbose = 'Limited';
        break;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
        verbose = 'Denied';
        break;
      default:
        verbose = 'Unknown';
        break;
    }

    return verbose;
  }

  bool isEqual(PermissionStatus otherStatus) {
    return index == otherStatus.index;
  }
}
