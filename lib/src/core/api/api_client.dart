import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'https://lms-latest-dsrn.onrender.com/api';
  final SharedPreferences _prefs;

  ApiClient(this._prefs);

  // Token management
  Future<String?> getAccessToken() async {
    return _prefs.getString('access_token');
  }

  Future<String?> getRefreshToken() async {
    return _prefs.getString('refresh_token');
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _prefs.setString('access_token', accessToken);
    await _prefs.setString('refresh_token', refreshToken);
  }

  Future<void> clearTokens() async {
    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');
    await _prefs.remove('user_data');
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  // GET request
  Future<http.Response> get(String endpoint) async {
    final token = await getAccessToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    print('🔑 Making GET request to: $baseUrl$endpoint');
    if (token != null) {
      print('🔑 Adding Bearer token');
    } else {
      print('⚠️ No access token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    print('📊 Response status: ${response.statusCode}');
    print('📄 Response body: ${response.body}');

    return response;
  }

  // POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final token = await getAccessToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    print('🔑 Making POST request to: $baseUrl$endpoint');
    if (token != null) {
      print('🔑 Adding Bearer token');
    }

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );

    print('📊 Response status: ${response.statusCode}');
    print('📄 Response body: ${response.body}');

    return response;
  }

  // PUT request
  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final token = await getAccessToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    print('🔑 Making PUT request to: $baseUrl$endpoint');
    if (token != null) {
      print('🔑 Adding Bearer token');
    }

    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );

    print('📊 Response status: ${response.statusCode}');
    print('📄 Response body: ${response.body}');

    return response;
  }

  // DELETE request
  Future<http.Response> delete(String endpoint) async {
    final token = await getAccessToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    print('🔑 Making DELETE request to: $baseUrl$endpoint');
    if (token != null) {
      print('🔑 Adding Bearer token');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    print('📊 Response status: ${response.statusCode}');
    print('📄 Response body: ${response.body}');

    return response;
  }
}
