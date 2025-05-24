import 'package:flutter/material.dart';
import 'json_theme.dart';
import 'json_router.dart';
import 'json_widget_tree.dart';

class DynamicApp extends StatelessWidget {
  final Map<String, dynamic> config;
  const DynamicApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final themeData =
        JsonThemeInterpreter(
          config['theme'],
          config['textStyles'],
        ).toThemeData();
    return MaterialApp(
      title: config['appName'] ?? 'Dynamic App',
      theme: themeData,
      onGenerateRoute:
          (settings) =>
              JsonRouterInterpreter(config['routes']).onGenerateRoute(settings),
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}
