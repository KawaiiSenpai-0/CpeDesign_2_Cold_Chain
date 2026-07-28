class SensorData {
  final double temperature;
  final double humidity;
  final int co2;

  final String prediction;

  final String lstmPrediction;
  final double lstmConfidence;

  final String rfPrediction;
  final double rfConfidence;

  final double avgTemperature;
  final double avgHumidity;
  final int avgCo2;

  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.co2,

    required this.prediction,

    required this.lstmPrediction,
    required this.lstmConfidence,

    required this.rfPrediction,
    required this.rfConfidence,

    required this.avgTemperature,
    required this.avgHumidity,
    required this.avgCo2,

    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json["temperature"] as num).toDouble(),
      humidity: (json["humidity"] as num).toDouble(),
      co2: (json["co2"] as num).toInt(),

      prediction: json["prediction"] as String? ?? "At Risk",

      lstmPrediction: json["lstm_prediction"] as String? ?? "At Risk",

      lstmConfidence: (json["lstm_confidence"] as num? ?? 0).toDouble(),

      rfPrediction: json["rf_prediction"] as String? ?? "At Risk",

      rfConfidence: (json["rf_confidence"] as num? ?? 0).toDouble(),

      avgTemperature: (json["avgTemperature"] as num? ?? 0).toDouble(),

      avgHumidity: (json["avgHumidity"] as num? ?? 0).toDouble(),

      avgCo2: (json["avgCo2"] as num? ?? 0).toInt(),

      timestamp: DateTime.parse(json["timestamp"] as String),
    );
  }
}
