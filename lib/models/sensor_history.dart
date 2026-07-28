import 'sensor_data.dart';

class SensorHistory {
  final List<SensorData> readings;

  SensorHistory({required this.readings});

  double get averageTemperature {
    if (readings.isEmpty) return 0;

    double total = 0;

    for (var data in readings) {
      total += data.temperature;
    }

    return total / readings.length;
  }

  double get averageHumidity {
    if (readings.isEmpty) return 0;

    double total = 0;

    for (var data in readings) {
      total += data.humidity;
    }

    return total / readings.length;
  }

  double get averageCO2 {
    if (readings.isEmpty) return 0;

    double total = 0;

    for (var data in readings) {
      total += data.co2;
    }

    return total / readings.length;
  }
}
