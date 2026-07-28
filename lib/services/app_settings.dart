import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  static const _backendUrlKey = 'backend_url';
  static const _refreshSecondsKey = 'refresh_seconds';
  static const _notificationsKey = 'notifications_enabled';

  int _refreshSeconds = 5;
  bool _notificationsEnabled = true;
  bool _hasConfiguredBackend = false;
  SharedPreferences? _preferences;

  int get refreshSeconds => _refreshSeconds;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get hasConfiguredBackend => _hasConfiguredBackend;

  Future<void> load() async {
    _preferences = await SharedPreferences.getInstance();

    final savedUrl = _preferences!.getString(_backendUrlKey);
    if (savedUrl != null && savedUrl.isNotEmpty) {
      ApiConfig.setBaseUrl(savedUrl);
      _hasConfiguredBackend = true;
    }

    switch (_preferences!.getInt(_refreshSecondsKey)) {
      case 5:
      case 10:
      case 30:
        _refreshSeconds = _preferences!.getInt(_refreshSecondsKey)!;
      default:
        break;
    }
    _notificationsEnabled = _preferences!.getBool(_notificationsKey) ?? true;
  }

  Future<void> saveBackendUrl(String value) async {
    ApiConfig.setBaseUrl(value);
    await _preferences!.setString(_backendUrlKey, ApiConfig.baseUrl);
    _hasConfiguredBackend = true;
    notifyListeners();
  }

  Future<void> setRefreshSeconds(int value) async {
    if (value != 5 && value != 10 && value != 30) return;
    _refreshSeconds = value;
    await _preferences!.setInt(_refreshSecondsKey, value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _preferences!.setBool(_notificationsKey, value);
    notifyListeners();
  }
}
