import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/private_item.dart';

class PrivateStorageService {
  static const String baseUrl = 'http://localhost:8000/api/v1';

  Future<Map<String, dynamic>> getStatus(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/private-storage/status'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get private storage status: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> unlock(String token, {String? pattern, String? pin}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/private-storage/unlock'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({
        if (pattern != null) 'pattern': pattern,
        if (pin != null) 'pin': pin,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to unlock private storage: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<PrivateItem>> getItems(String token, {String? itemType}) async {
    final uri = Uri.parse('$baseUrl/private-storage/items').replace(
      queryParameters: itemType != null ? {'item_type': itemType} : null,
    );
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => PrivateItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get private items: ${response.statusCode} ${response.body}');
    }
  }

  Future<PrivateItem> createItem(
    String token,
    String itemType,
    String encryptedData,
    Map<String, dynamic>? metadata,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/private-storage/items'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'item_type': itemType,
        'encrypted_data': encryptedData,
        'metadata': metadata,
      }),
    );
    if (response.statusCode == 201) {
      return PrivateItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create private item: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteItem(String token, String itemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/private-storage/items/$itemId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete private item: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> setup(String token, {String? pattern, String? pin}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/private-storage/setup'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({
        if (pattern != null) 'pattern': pattern,
        if (pin != null) 'pin': pin,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to setup private storage: ${response.statusCode} ${response.body}');
    }
  }
} 