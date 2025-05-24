import 'package:flutter/material.dart';
import 'json_widget_tree.dart';

class JsonRouterInterpreter {
  final Map<String, dynamic> routes;
  JsonRouterInterpreter(this.routes);

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeConfig = routes[settings.name];
    if (routeConfig == null) {
      return MaterialPageRoute(
        builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: \'${settings.name}\''))),
      );
    }
    return MaterialPageRoute(
      builder: (_) => JsonWidgetTreeInterpreter(routeConfig),
    );
  }
}
