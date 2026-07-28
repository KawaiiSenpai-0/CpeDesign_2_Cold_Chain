import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/sensor_data.dart';
import '../models/sensor_history.dart';

class HistoryService {
  Future<SensorHistory> fetchHistory() async {
    final response = await http
        .get(Uri.parse("${ApiConfig.baseUrl}/history"))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch history");
    }

    final List<dynamic> json = jsonDecode(response.body);

    List<SensorData> readings = json.map((item) {
      return SensorData(
        temperature: (item["temperature"] as num).toDouble(),
        humidity: (item["humidity"] as num).toDouble(),
        co2: (item["co2"] as num).toInt(),

        prediction: item["prediction"] ?? "At Risk",

        lstmPrediction:
            item["lstm_prediction"] ?? item["prediction"] ?? "At Risk",

        lstmConfidence: ((item["lstm_confidence"] ?? 0.0) as num).toDouble(),

        rfPrediction: item["rf_prediction"] ?? item["prediction"] ?? "At Risk",

        rfConfidence: ((item["rf_confidence"] ?? 0.0) as num).toDouble(),

        avgTemperature: 0,
        avgHumidity: 0,
        avgCo2: 0,

        timestamp: DateTime.parse(item["timestamp"]),
      );
    }).toList();

    return SensorHistory(readings: readings);
  }
}
