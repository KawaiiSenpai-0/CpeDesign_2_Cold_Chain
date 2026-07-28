import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/device_info.dart';

class DeviceService {
  Future<DeviceInfo> fetchDeviceInfo() async {
    final response = await http
        .get(Uri.parse("${ApiConfig.baseUrl}/device-info"))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Failed to load device information");
    }

    return DeviceInfo.fromJson(jsonDecode(response.body));
  }
}
