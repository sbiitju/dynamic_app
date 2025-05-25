import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:campus_sheba/dynamic_app.dart';
import 'package:yaml/yaml.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load YAML config from assets (assets/app_config.yaml)
  final String configString = await rootBundle.loadString(
    'assets/app_config.yaml',
  );
  final dynamic config = loadYaml(configString);
  // Convert YamlMap to Map<String, dynamic>
  final Map<String, dynamic> configMap = _yamlToMap(config);
  runApp(DynamicApp(config: configMap));
}

// Helper to convert YamlMap/YamlList to Map<String, dynamic>/List recursively
dynamic _yamlToMap(dynamic yaml) {
  if (yaml is YamlMap) {
    return Map<String, dynamic>.fromEntries(
      yaml.entries.map((e) => MapEntry(e.key.toString(), _yamlToMap(e.value))),
    );
  } else if (yaml is YamlList) {
    return yaml.map(_yamlToMap).toList();
  } else {
    return yaml;
  }
}
