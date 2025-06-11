import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/breach_alert.dart';
import '../models/activity_notification.dart';
import '../models/password.dart';
import '../models/social_account.dart';
import '../models/private_item.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email,
        'password': password
      }.entries.map((e) => '${e.key}=${e.value}').join('&'),
    );

    if (response.statusCode == 200) {
      print('Login successful! Response status: ${response.statusCode}, body: ${response.body}');
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to login: Empty response body on 200 OK');
      }
    } else {
      throw Exception('Failed to login: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
        }),
      );

      if (response.statusCode == 201) {
        // Registration successful
        return;
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Registration failed');
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to connect to server');
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  // Password API calls
  Future<List<Password>> getPasswords(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/passwords/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Password.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get passwords: ${response.statusCode} ${response.body}');
    }
  }

  Future<Password> createPassword(String token, Map<String, dynamic> passwordData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/passwords/'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode(passwordData),
    );
    if (response.statusCode == 201) {
      return Password.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create password: ${response.statusCode} ${response.body}');
    }
  }

  Future<Password> updatePassword(String token, String passwordId, Map<String, dynamic> passwordData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/passwords/$passwordId'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode(passwordData),
    );
    if (response.statusCode == 200) {
      return Password.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update password: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deletePassword(String token, String passwordId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/passwords/$passwordId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete password: ${response.statusCode} ${response.body}');
    }
  }

  // Social Account API calls
  Future<List<SocialAccount>> getSocialAccounts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/social/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => SocialAccount.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get social accounts: ${response.statusCode} ${response.body}');
    }
  }

  Future<SocialAccount> createSocialAccount(String token, Map<String, dynamic> accountData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/social/'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode(accountData),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return SocialAccount.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create social account: ${response.statusCode} ${response.body}');
    }
  }

  Future<SocialAccount> updateSocialAccount(String token, String accountId, Map<String, dynamic> accountData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/social/$accountId'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode(accountData),
    );
    if (response.statusCode == 200) {
      return SocialAccount.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update social account: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteSocialAccount(String token, String accountId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/social/$accountId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete social account: ${response.statusCode} ${response.body}');
    }
  }

  // Breach Monitor API calls
  Future<List<BreachAlert>> checkPasswordsForBreach(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/breach/check-passwords'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => BreachAlert.fromJson(item)).toList();
    } else {
      throw Exception('Failed to check passwords for breach');
    }
  }

  Future<List<BreachAlert>> checkEmailForBreach(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/breach/check-email'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => BreachAlert.fromJson(item)).toList();
    } else {
      throw Exception('Failed to check email for breach');
    }
  }

  Future<List<BreachAlert>> getBreachAlerts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/breach/alerts'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => BreachAlert.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get breach alerts');
    }
  }

  Future<BreachAlert> resolveBreachAlert(String token, String alertId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/breach/alerts/$alertId/resolve'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return BreachAlert.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to resolve breach alert');
    }
  }

  // Activity Notification API calls
  Future<List<ActivityNotification>> getActivityNotifications(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => ActivityNotification.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get activity notifications');
    }
  }

  Future<ActivityNotification> markNotificationAsRead(String token, String notificationId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return ActivityNotification.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to mark notification as read');
    }
  }

  // User Profile Management API calls
  Future<Map<String, dynamic>> updateUserProfile(String token, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/me'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update user profile: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> updateUserPassword(String token, String currentPassword, String newPassword) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/me/password'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'current_password': currentPassword, 'new_password': newPassword}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update password: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteUserAccount(String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete user account: ${response.statusCode} ${response.body}');
    }
  }
} 