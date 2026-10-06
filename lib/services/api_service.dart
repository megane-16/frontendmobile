import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/school_model.dart';

class ApiService {
  // Changer cette valeur selon l'environnement
  static bool isEmulator = true;
  static String emulatorUrl = 'http://127.0.0.1:8000/api';
  static String physicalDeviceUrl =
      'https://autoecole-project1-jqin.kennhosting.app/api'; // Mise à jour avec la bonne IP

  static String baseUrl = 'https://autoecole-project1-jqin.kennhosting.app/api';

  Future<Map<String, String>> _getHeaders() async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Récupération du token pour les requêtes authentifiées (Sanctum)
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      final userData = json.decode(prefs.getString('userData')!);
      final token = userData['token'];
      if (token != null && token.toString().isNotEmpty) {
        headers['Authorization'] = 'Bearer \$token';
      }
    }

    return headers;
  }

  // --- Auth ---
  Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: await _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson({
          ...Map<String, dynamic>.from(data['user'] as Map),
          'token': data['access_token'],
        });
      }

      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Identifiants invalides');
    } catch (e) {
      debugPrint('Erreur Login: $e');
    }
    return null;
  }

  Future<User?> loginByCode(String code) async {
    debugPrint("DEBUG: Tentative de loginByCode avec le code: $code");
    debugPrint("DEBUG: URL: $baseUrl/login-by-code");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login-by-code'),
        headers: await _getHeaders(),
        body: jsonEncode({'code': code.trim().toUpperCase()}),
      );

      debugPrint("DEBUG: Response Status: ${response.statusCode}");
      debugPrint("DEBUG: Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson({
          ...Map<String, dynamic>.from(data['user'] as Map),
          'token': data['access_token'],
        });
      }

      final data = jsonDecode(response.body);
      debugPrint("DEBUG: Erreur API: ${data['message']}");
      throw Exception(data['message'] ?? 'Code invalide');
    } catch (e) {
      debugPrint('Erreur LoginByCode: $e');
      rethrow;
    }
  }

  Future<dynamic> register(Map<String, dynamic> userData) async {
    try {
      debugPrint('--- TENTATIVE D\'INSCRIPTION ---');
      debugPrint('URL: $baseUrl/register');
      debugPrint('PAYLOAD: ${jsonEncode(userData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: await _getHeaders(),
        body: jsonEncode(userData),
      );

      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('REPONSE BRUTE: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('INSCRIPTION RÉUSSIE DANS LARAVEL');
        return data;
      } else {
        String errorMsg = data['message'] ?? 'Erreur inconnue';
        if (data['errors'] != null) {
          errorMsg = "Erreurs de validation: ${data['errors'].toString()}";
        }
        debugPrint('ÉCHEC INSCRIPTION: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('EXCEPTION LORS DE L\'INSCRIPTION: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Impossible de fermer la session');
    }
  }

  // --- Auto-écoles ---
  Future<List<School>> getAutoEcoles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auto-ecoles'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> autoEcolesJson = data['auto_ecoles'] ?? [];
        return autoEcolesJson.map((json) => School.fromJson(json)).toList();
      }

      // Fallback sur les données de test si l'API n'est pas encore prête
      return [
        School(
          id: 3,
          name: "Auto-école Paris",
          description: "Expertise et professionnalisme",
          imagePath: "assets/images/autostop.svg",
          location: "Douala, Bonapriso",
        ),
        School(
          id: 4,
          name: "Kopa",
          description: "Apprentissage rapide",
          imagePath: "assets/images/autostop1.svg",
          location: "Yaoundé, Mvan",
        ),
      ];
    } catch (e) {
      debugPrint('Erreur getAutoEcoles: $e');
      return [];
    }
  }

  // --- Upload CNI ---
  Future<bool> uploadCNI(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl.replaceAll('/api', '')}/upload-cni'),
      );

      final headers = await _getHeaders();
      headers.remove('Content-Type'); // MultipartRequest définit sa boundary.
      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath('cni', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Erreur Upload CNI: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> analyzeTrafficSign(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/traffic-signs/analyze'),
    );
    final headers = await _getHeaders();
    headers.remove('Content-Type'); // Ne pas remplacer le boundary multipart.
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await http.Response.fromStream(await request.send());
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Analyse impossible');
    }
    return Map<String, dynamic>.from(body['data'] as Map);
  }

  Future<Map<String, dynamic>> getLearnerDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/mobile/dashboard'),
   
      headers: await _getHeaders(),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Dashboard indisponible');
    }

    return body;
  }

  Future<List<Map<String, dynamic>>> getCourses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/courses'),
      headers: await _getHeaders(),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Impossible de charger les cours');
    }

    final courses = body['data'] ?? body['courses'] ?? [];
    return List<Map<String, dynamic>>.from(courses is List ? courses : []);
  }

  // --- Profil & Sécurité ---
  Future<User> updateProfile({
    String? name,
    String? telephone,
    String? ville,
    File? photo,
  }) async {
    final uri = Uri.parse('$baseUrl/profile/update');
    final headers = await _getHeaders();

    if (photo != null) {
      final request = http.MultipartRequest('POST', uri);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      if (name != null) request.fields['name'] = name;
      if (telephone != null) request.fields['telephone'] = telephone;
      if (ville != null) request.fields['ville'] = ville;

      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        String msg = body['message'] ?? 'Erreur lors de la mise à jour';
        if (body['errors'] != null) {
          msg = (body['errors'] as Map).values.first[0];
        }
        throw Exception(msg);
      }

      final prefs = await SharedPreferences.getInstance();
      final updatedUser = User.fromJson(Map<String, dynamic>.from(body['user'] as Map));
      if (prefs.containsKey('userData')) {
        final currentData = jsonDecode(prefs.getString('userData')!) as Map<String, dynamic>;
        currentData.addAll(updatedUser.toJson());
        await prefs.setString('userData', jsonEncode(currentData));
      }

      return updatedUser;
    } else {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'name': ?name,
          'telephone': ?telephone,
          'ville': ?ville,
        }),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        String msg = body['message'] ?? 'Erreur lors de la mise à jour';
        if (body['errors'] != null) {
          msg = (body['errors'] as Map).values.first[0];
        }
        throw Exception(msg);
      }

      final prefs = await SharedPreferences.getInstance();
      final updatedUser = User.fromJson(Map<String, dynamic>.from(body['user'] as Map));
      if (prefs.containsKey('userData')) {
        final currentData = jsonDecode(prefs.getString('userData')!) as Map<String, dynamic>;
        currentData.addAll(updatedUser.toJson());
        await prefs.setString('userData', jsonEncode(currentData));
      }

      return updatedUser;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profile/password'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      String msg = body['message'] ?? 'Erreur lors du changement de mot de passe';
      if (body['errors'] != null) {
        msg = (body['errors'] as Map).values.first[0];
      }
      throw Exception(msg);
    }
  }
}
