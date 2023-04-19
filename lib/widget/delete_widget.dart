import 'package:flutter/material.dart';

Container deleteWidget() {
  return Container(
    color: Colors.red,
    child: const Align(
      alignment: Alignment.centerRight,
      child: Icon(
        color: Colors.white,
        Icons.delete,
      ),
    ),
  );
}
