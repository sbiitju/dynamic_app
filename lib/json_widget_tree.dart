import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JsonWidgetTreeInterpreter extends StatelessWidget {
  final Map<String, dynamic> json;
  JsonWidgetTreeInterpreter(this.json, {super.key});

  // Controllers for text fields and checkboxes
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _boolControllers = {};

  @override
  Widget build(BuildContext context) {
    return _buildWidget(json, context);
  }

  // Recursively builds widgets from JSON config
  Widget _buildWidget(Map<String, dynamic> node, BuildContext context) {
    final type = node['widget'];
    switch (type) {
      case 'Scaffold':
        // Always wrap body in 16 padding
        Widget? bodyWidget =
            node['body'] != null ? _buildWidget(node['body'], context) : null;
        bodyWidget = Padding(
          padding: const EdgeInsets.all(16),
          child: bodyWidget,
        );
        return Scaffold(
          appBar:
              node['appBar'] != null
                  ? _buildWidget(node['appBar'], context)
                      as PreferredSizeWidget?
                  : null,
          body: bodyWidget,
        );
      case 'AppBar':
        return AppBar(
          title:
              node['title'] != null
                  ? _buildWidget(node['title'], context)
                  : null,
        );
      case 'Column':
        return Column(
          mainAxisSize: MainAxisSize.max,
          spacing: node['spacing'] != null ? node['spacing'].toDouble() : 0,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              node['mainAxisAlignment'] == 'center'
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
          children:
              (node['children'] as List<dynamic>? ?? [])
                  .map((child) => _buildWidget(child, context))
                  .toList(),
        );
      case 'Row':
        return Row(
          mainAxisSize: MainAxisSize.max,
          children:
              (node['children'] as List<dynamic>? ?? [])
                  .map((child) => _buildWidget(child, context))
                  .toList(),
        );
      case 'Text':
        return Text(
          node['data'] ?? '',
          style: node['style'] != null ? _parseTextStyle(node['style']) : null,
        );
      case 'TextField':
        final controllerName = node['controller'];
        if (controllerName != null &&
            !_controllers.containsKey(controllerName)) {
          _controllers[controllerName] = TextEditingController();
        }
        // Always use outlined border
        return TextField(
          controller:
              controllerName != null ? _controllers[controllerName] : null,
          obscureText: node['obscureText'] == true,
          decoration: InputDecoration(
            hintText:
                node['decoration'] != null
                    ? node['decoration']['hintText']
                    : null,
            border: const OutlineInputBorder(),
          ),
        );
      case 'SingleChildScrollView':
        return SingleChildScrollView(
          child:
              node['child'] != null
                  ? _buildWidget(node['child'], context)
                  : null,
        );
      case 'Checkbox':
        final controllerName = node['controller'];
        if (controllerName != null &&
            !_boolControllers.containsKey(controllerName)) {
          _boolControllers[controllerName] = false;
        }
        // Use StatefulBuilder to manage checkbox state locally
        return StatefulBuilder(
          builder: (context, setState) {
            return Checkbox(
              value:
                  controllerName != null
                      ? _boolControllers[controllerName]
                      : false,
              onChanged: (val) {
                if (controllerName != null) {
                  setState(() {
                    _boolControllers[controllerName] = val ?? false;
                  });
                }
              },
            );
          },
        );
      case 'ElevatedButton':
        // Make button full width using SizedBox and double.infinity
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (node['action'] != null) {
                final action = node['action'];
                if (action['type'] == 'login') {
                  final username = _controllers['username']?.text ?? '';
                  final password = _controllers['password']?.text ?? '';
                  await login(context, username, password);
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Action: ${node['action']['type']}')),
                );
              }
            },
            child: Text(node['text'] ?? 'Button'),
          ),
        );
      case 'TextButton':
        return TextButton(
          onPressed: () {
            if (node['onPressed'] != null) {
              final onPressed = node['onPressed'];
              if (onPressed['type'] == 'navigate' &&
                  onPressed['route'] != null) {
                Navigator.of(context).pushNamed(onPressed['route']);
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('onPressed: ${onPressed['type']}')),
              );
            }
          },
          child: Text(node['text'] ?? 'TextButton'),
        );
      case 'GestureDetector':
        return GestureDetector(
          onTap: () {
            if (node['onTap'] != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('onTap: ${node['onTap']['type']}')),
              );
            }
          },
          child:
              node['child'] != null
                  ? _buildWidget(node['child'], context)
                  : null,
        );
      case 'Padding':
        final paddingValue = node['padding'];
        EdgeInsets padding;
        if (paddingValue is num) {
          padding = EdgeInsets.all(paddingValue.toDouble());
        } else if (paddingValue is Map<String, dynamic>) {
          padding = EdgeInsets.only(
            left: (paddingValue['left'] ?? 0).toDouble(),
            top: (paddingValue['top'] ?? 0).toDouble(),
            right: (paddingValue['right'] ?? 0).toDouble(),
            bottom: (paddingValue['bottom'] ?? 0).toDouble(),
          );
        } else {
          padding = EdgeInsets.zero;
        }
        return Padding(
          padding: padding,
          child:
              node['child'] != null
                  ? _buildWidget(node['child'], context)
                  : null,
        );
      case 'Center':
        return Center(
          child:
              node['child'] != null
                  ? _buildWidget(node['child'], context)
                  : null,
        );
      default:
        return SizedBox.shrink();
    }
  }

  // Parses text style from JSON
  TextStyle? _parseTextStyle(Map<String, dynamic>? style) {
    if (style == null) return null;
    return TextStyle(
      color: style['color'] != null ? _parseColor(style['color']) : null,
      decoration:
          style['decoration'] == 'underline' ? TextDecoration.underline : null,
    );
  }

  // Parses color from hex string
  Color? _parseColor(dynamic colorString) {
    if (colorString is String && colorString.startsWith('#')) {
      final hex = colorString.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }
    return null;
  }

  // Handles login network request, response, and token storage
  Future<void> login(
    BuildContext context,
    String username,
    String password,
  ) async {
    try {
      final payload = {'username': username, 'password': password};
      print('Login request payload: ' + jsonEncode(payload));
      final response = await http.post(
        Uri.parse('https://wega.test.simetrix.ch/backend/api/v3/auth/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      print('Login response: ' + response.body);
      final data = jsonDecode(response.body);
      if (data['message'] == 'Authentication successful') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['result'] ?? '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login successful')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }
}
