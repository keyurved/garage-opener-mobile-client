import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SharedPreferencesHelper {
  static final String _kServerUrl = "serverUrl";
  static final String _kUsername = "username";
  static final String _kPassword = "password";
  static final String _kRememberUser = "rememberUser";
  static final String _kRememberPass = "rememberPass";
  static final String _kDelay = "delay";
  static final FlutterSecureStorage storage = new FlutterSecureStorage();

  static Future<String> getServerUrl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kServerUrl) ?? "";
  }

  static Future<bool> setServerUrl(String url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kServerUrl, url);
  }

  static Future<String> getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kUsername) ?? "";
  }

  static Future<bool> setUsername(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kUsername, username);
  }

  static Future<String> getPassword() async {
    return await storage.read(key: _kPassword) ?? "";
  }

  static setPassword(String password) async {
    await storage.write(key: _kPassword, value: password);
  }

  static Future<bool> setRememberUser(bool rememberUser) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(_kRememberUser, rememberUser);
  }

  static Future<bool> getRememberUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_kRememberUser) ?? false;
  }

  static Future<bool> setRememberPassword(bool rememberPass) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(_kRememberPass, rememberPass);
  }

  static Future<bool> getRememberPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_kRememberPass) ?? false;
  }

  static Future<bool> setDelay(int delay) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt(_kDelay, delay);
  }

  static Future<int> getDelay() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_kDelay) ?? 7;
  }
}
