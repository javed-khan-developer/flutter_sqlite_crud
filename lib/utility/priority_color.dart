import 'package:flutter/material.dart';

Color priorityColor(String value) {
  switch (value) {
    case 'Low':
      return Colors.green;
    case "Medium":
      return Colors.yellow;
    case "High":
      return Colors.red;
    default:
      return Colors.green;
  }
}
