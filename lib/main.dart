import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:campus_sheba/dynamic_app.dart';
import 'package:yaml/yaml.dart';

Future<Map<String, dynamic>> loadYamlFile(String path) async {
  final String yamlString = await rootBundle.loadString(path);
  final dynamic yamlData = loadYaml(yamlString);
  return _yamlToMap(yamlData);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await loadYamlFile('assets/config/app_config.yaml');
  final components = await loadYamlFile('assets/config/components.yaml');
  final widgets = await loadYamlFile('assets/config/widgets.yaml');

  // Merge all into a single config map for $ref resolution
  final mergedConfig = {
    ...config,
    '_components': components,
    '_widgets': widgets,
  };

  runApp(DynamicApp(config: mergedConfig));
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
