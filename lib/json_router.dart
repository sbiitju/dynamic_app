import 'package:flutter/material.dart';
import 'json_widget_tree.dart';

class JsonRouterInterpreter {
  final Map<String, dynamic> fullConfig;
  JsonRouterInterpreter(this.fullConfig);

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeConfig = fullConfig['routes'][settings.name];
    if (routeConfig == null) {
      return MaterialPageRoute(
        builder:
            (_) => Scaffold(
              body: Center(
                child: Text('Route not found: \'${settings.name}\''),
              ),
            ),
      );
    }
    return MaterialPageRoute(
      builder:
          (_) =>
              JsonWidgetTreeInterpreter(routeConfig, mergedConfig: fullConfig),
    );
  }
}
