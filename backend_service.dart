// lib/services/backend_service.dart
// A minimal HTTP client for a backend (not used directly in the demo but provided for completeness).

import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendService {
  final String baseUrl;
  BackendService(this.baseUrl);

  Future<Map<String, dynamic>> fetchProposal() async {
    final resp = await http.get(Uri.parse('$baseUrl/api/proposal'));
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Failed to fetch proposal');
  }

  Future<Map<String, dynamic>> runSimulation(Map<String, dynamic> params) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/simulate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(params),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Simulation failed');
  }
}
