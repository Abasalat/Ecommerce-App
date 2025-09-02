import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_endpoints.dart';

class ApiClient {
  const ApiClient();

  Future<Map<String, dynamic>> getJson(String url) async {
    final uri = Uri.parse(url);
    final res = await http
        .get(uri, headers: Map<String, String>.from(ApiEndpoints.headers))
        .timeout(ApiEndpoints.connectionTimeout);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body.isEmpty ? '{}' : res.body;
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      // When API returns a list (e.g., categories), wrap it
      return {'data': decoded};
    }
    throw Exception('GET ${uri.toString()} failed: ${res.statusCode}');
  }
}
