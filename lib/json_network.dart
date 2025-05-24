import 'dart:convert';
import 'package:http/http.dart' as http;

class JsonNetworkInterpreter {
  final Map<String, dynamic> endpoints;
  JsonNetworkInterpreter(this.endpoints);

  Future<dynamic> callEndpoint(String name,
      {Map<String, dynamic>? params}) async {
    final endpoint = endpoints[name];
    if (endpoint == null) return null;
    final url = endpoint['url'];
    final method = (endpoint['method'] ?? 'GET').toUpperCase();
    if (method == 'GET') {
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      return json.decode(response.body);
    } else if (method == 'POST') {
      final uri = Uri.parse(url);
      final response = await http.post(uri, body: params);
      return json.decode(response.body);
    }
    return null;
  }
}
