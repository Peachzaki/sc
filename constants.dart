import 'package:flutter/material.dart';

class Constants {
  // API Configuration
  static const String apiBaseUrl = 'https://your-api-endpoint.com';

  // Colors
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color primaryDarkColor = Color(0xFF1565C0);
  static const Color backgroundColor = Color(0xFFE3F2FD);
  static const Color headerColor = Color(0xFF90CAF9);
  static const Color darkBlue = Color(0xFF0D47A1);

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24,
    color: Colors.white,
    fontWeight: FontWeight.w300,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.white70,
  );

  static const TextStyle headerTextStyle = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: darkBlue,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle valueStyle = TextStyle(
    fontSize: 16,
  );
}