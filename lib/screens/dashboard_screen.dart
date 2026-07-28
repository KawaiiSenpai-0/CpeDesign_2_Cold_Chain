import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/api_service.dart';
import '../services/app_settings.dart';
import '../widgets/sensor_card.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService apiService = ApiService();
  SensorData? sensorData;
  bool loading = true;
  bool isOnline = true;
  String? errorMessage;
  Timer? timer;
  DateTime? lastFetched;
  final AppSettings settings = AppSettings.instance;

  @override
  void initState() {
    super.initState();
    settings.addListener(_restartRefreshTimer);
    loadData();
    _restartRefreshTimer();
  }

  void _restartRefreshTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: settings.refreshSeconds), (_) {
      loadData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    settings.removeListener(_restartRefreshTimer);
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final data = await apiService.fetchSensorData();

      if (!mounted) return;
      setState(() {
        sensorData = data;
        loading = false;
        isOnline = true;
        errorMessage = null;
        lastFetched = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        isOnline = false;
        errorMessage = sensorData == null
            ? "Unable to reach ColdSense. Check that the backend is running."
            : "Backend is temporarily unavailable. Showing the last received reading.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ColdSense"),
        actions: [
          IconButton(
            onPressed: loadData,
            tooltip: 'Refresh now',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      // Show a loading indicator if data is still fetching
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (errorMessage != null) ...[
                    Card(
                      color: Colors.red.withValues(alpha: 0.16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_off, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(child: Text(errorMessage!)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // 1. Header (Title & Subtitle)
                  const Text(
                    "ColdSense",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "AI-Based Cold Chain Monitoring",
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // 2. System Status Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            isOnline ? Icons.check_circle : Icons.error,
                            color: isOnline ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isOnline ? "System Online" : "System Offline",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. Last Updated Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Last Updated",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sensorData == null
                                ? "--"
                                : sensorData!.timestamp.toLocal().toString(),
                            style: const TextStyle(fontSize: 18),
                          ),
                          if (lastFetched != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Fetched ${_timeAgo(lastFetched!)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Device Information Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Device Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          const ListTile(
                            leading: Icon(Icons.memory),
                            title: Text("Device"),
                            subtitle: Text("ColdSense Node 01"),
                          ),
                          ListTile(
                            leading: Icon(
                              isOnline ? Icons.cloud_done : Icons.cloud_off,
                              color: isOnline ? Colors.green : Colors.red,
                            ),
                            title: const Text("Backend"),
                            subtitle: Text(
                              isOnline ? "Connected" : "Disconnected",
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.sync),
                            title: Text("Refresh Interval"),
                            subtitle: Text(
                              "${settings.refreshSeconds} seconds",
                            ),
                          ),
                          const ListTile(
                            leading: Icon(Icons.storage),
                            title: Text("Database"),
                            subtitle: Text("SQLite"),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. Sensor Cards
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                    children: [
                      SensorCard(
                        icon: Icons.thermostat,
                        title: "Temperature",
                        value: sensorData != null
                            ? "${sensorData!.temperature.toStringAsFixed(1)} °C"
                            : "--",
                        subtitle: "Latest reading",
                        iconColor: Colors.orange,
                      ),

                      SensorCard(
                        icon: Icons.water_drop,
                        title: "Humidity",
                        value: sensorData != null
                            ? "${sensorData!.humidity.toStringAsFixed(1)} %"
                            : "--",
                        subtitle: "Relative humidity",
                        iconColor: Colors.blue,
                      ),

                      SensorCard(
                        icon: Icons.cloud,
                        title: "CO₂",
                        value: sensorData != null
                            ? "${sensorData!.co2} ppm"
                            : "--",
                        subtitle: "Carbon dioxide",
                        iconColor: Colors.teal,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Replacement AI Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.psychology, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                "AI Prediction",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const Divider(),

                          const Text(
                            "Final Prediction",
                            style: TextStyle(color: Colors.grey),
                          ),

                          Text(
                            sensorData?.prediction ?? "--",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            "LSTM",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          Text(sensorData?.lstmPrediction ?? "--"),

                          Text(
                            "${((sensorData?.lstmConfidence ?? 0) * 100).toStringAsFixed(1)} %",
                            style: const TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            "Random Forest",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          Text(sensorData?.rfPrediction ?? "--"),

                          Text(
                            "${((sensorData?.rfConfidence ?? 0) * 100).toStringAsFixed(1)} %",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 6. AI Decision Engine Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "AI Decision Engine",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.auto_graph),
                            title: const Text("LSTM Prediction"),
                            subtitle: Text(sensorData?.lstmPrediction ?? "--"),
                            trailing: Text(
                              sensorData == null
                                  ? "--"
                                  : "${(sensorData!.lstmConfidence * 100).toStringAsFixed(1)}%",
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.account_tree),
                            title: const Text("Random Forest"),
                            subtitle: Text(sensorData?.rfPrediction ?? "--"),
                            trailing: Text(
                              sensorData == null
                                  ? "--"
                                  : "${(sensorData!.rfConfidence * 100).toStringAsFixed(1)}%",
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(
                              Icons.verified,
                              color: Colors.green,
                            ),
                            title: const Text("Final Prediction"),
                            subtitle: Text(
                              sensorData?.prediction ?? "--",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _timeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inSeconds < 5) return 'just now';
    if (difference.inSeconds < 60) return '${difference.inSeconds} seconds ago';
    return '${difference.inMinutes} minutes ago';
  }
}
