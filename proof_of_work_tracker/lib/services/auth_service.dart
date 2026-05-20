import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<String> login(String username, String password) async {
    final res = await _api.post(
      ApiConstants.login,
      data: {'username': username, 'password': password},
    );
    final token = res.data['access_token'] as String;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    return token;
  }

  Future<String> register(
    String username,
    String email,
    String password,
  ) async {
    final res = await _api.post(
      ApiConstants.register,
      data: {'username': username, 'email': email, 'password': password},
    );
    final token = res.data['access_token'] as String;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    return token;
  }

  Future<UserModel> getMe() async {
    final res = await _api.get(ApiConstants.me);
    return UserModel.fromJson(res.data);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
