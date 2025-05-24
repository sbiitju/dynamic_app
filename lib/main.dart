import 'dart:convert';
import 'package:campus_sheba/dynamic_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load JSON config from assets (assets/app_config.json)
  final String configString = await rootBundle.loadString(
    'assets/app_config.json',
  );
  final Map<String, dynamic> config = json.decode(configString);
  runApp(DynamicApp(config: config));
}
