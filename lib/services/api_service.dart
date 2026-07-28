import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/sensor_data.dart';

class ApiService {
  Future<SensorData> fetchSensorData() async {
    final response = await http
        .get(Uri.parse("${ApiConfig.baseUrl}/latest"))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Failed to load sensor data");
    }

    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic> || !json.containsKey("temperature")) {
      throw Exception("No sensor data is available yet");
    }

    return SensorData.fromJson(json);
  }
}
