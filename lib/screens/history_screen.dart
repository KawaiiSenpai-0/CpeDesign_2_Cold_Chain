import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/sensor_history.dart';
import '../services/history_service.dart';
import '../services/app_settings.dart';
import 'dart:async';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService historyService = HistoryService();

  SensorHistory? history;
  bool loading = true;
  String? errorMessage;
  Timer? refreshTimer;
  final AppSettings settings = AppSettings.instance;

  @override
  void initState() {
    super.initState();
    settings.addListener(_restartRefreshTimer);
    loadHistory();
    _restartRefreshTimer();
  }

  void _restartRefreshTimer() {
    refreshTimer?.cancel();
    refreshTimer = Timer.periodic(Duration(seconds: settings.refreshSeconds), (
      timer,
    ) {
      loadHistory();
    });
  }

  Future<void> loadHistory() async {
    try {
      final data = await historyService.fetchHistory();

      if (!mounted) return;
      setState(() {
        history = data;
        loading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        errorMessage = 'Unable to load history. Check the backend connection.';
      });
    }
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    settings.removeListener(_restartRefreshTimer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        actions: [
          IconButton(
            onPressed: loadHistory,
            tooltip: 'Refresh now',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : history == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(errorMessage ?? 'No history is available.'),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: loadHistory,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =============================
                    // Temperature Graph
                    // =============================
                    const Text(
                      "Temperature Trend",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 250,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: true),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: history!.readings
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => FlSpot(
                                      entry.key.toDouble(),
                                      entry.value.temperature,
                                    ),
                                  )
                                  .toList(),
                              isCurved: true,
                              barWidth: 3,
                              color: Colors.orange,
                              dotData: const FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // =============================
                    // Humidity Graph
                    // =============================
                    const Text(
                      "Humidity Trend",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 250,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: true),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: history!.readings
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => FlSpot(
                                      entry.key.toDouble(),
                                      entry.value.humidity,
                                    ),
                                  )
                                  .toList(),
                              isCurved: true,
                              barWidth: 3,
                              color: Colors.blue,
                              dotData: const FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // =============================
                    // CO₂ Graph
                    // =============================
                    const Text(
                      "CO₂ Trend",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 250,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: true),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: history!.readings
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => FlSpot(
                                      entry.key.toDouble(),
                                      entry.value.co2.toDouble(),
                                    ),
                                  )
                                  .toList(),
                              isCurved: true,
                              barWidth: 3,
                              color: Colors.teal,
                              dotData: const FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // =============================
                    // Summary Card
                    // =============================
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Summary",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Average Temperature: ${history!.averageTemperature.toStringAsFixed(2)} °C",
                            ),
                            Text(
                              "Average Humidity: ${history!.averageHumidity.toStringAsFixed(2)} %",
                            ),
                            Text(
                              "Average CO₂: ${history!.averageCO2.toStringAsFixed(0)} ppm",
                            ),
                          ],
                        ),
                      ),
                    ),

                    // =============================
                    // Latest AI Analysis Card
                    // =============================
                    const SizedBox(height: 25),

                    if (history != null && history!.readings.isNotEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Latest AI Analysis",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              Text(
                                "LSTM Prediction: "
                                "${history!.readings.last.lstmPrediction}",
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                "Confidence: "
                                "${(history!.readings.last.lstmConfidence * 100).toStringAsFixed(2)} %",
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Random Forest Prediction: "
                                "${history!.readings.last.rfPrediction}",
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                "Confidence: "
                                "${(history!.readings.last.rfConfidence * 100).toStringAsFixed(2)} %",
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const Divider(height: 30),
                              Text(
                                "Final Prediction",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                history!.readings.last.prediction,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
