import 'package:flutter/material.dart';
import '../models/device_info.dart';
import '../services/device_service.dart';
import '../services/app_settings.dart';
import 'dart:async';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final DeviceService deviceService = DeviceService();

  DeviceInfo? device;

  bool loading = true;

  Timer? refreshTimer;
  final AppSettings settings = AppSettings.instance;

  @override
  void initState() {
    super.initState();
    settings.addListener(_restartRefreshTimer);
    loadDevice();
    _restartRefreshTimer();
  }

  void _restartRefreshTimer() {
    refreshTimer?.cancel();
    refreshTimer = Timer.periodic(Duration(seconds: settings.refreshSeconds), (
      timer,
    ) {
      loadDevice();
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    settings.removeListener(_restartRefreshTimer);
    super.dispose();
  }

  Future<void> loadDevice() async {
    try {
      final data = await deviceService.fetchDeviceInfo();

      if (!mounted) return;
      setState(() {
        device = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  String timeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);

    if (difference.inSeconds < 5) {
      return "Just now";
    }

    if (difference.inSeconds < 60) {
      return "${difference.inSeconds} seconds ago";
    }

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    }

    if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    }

    return "${difference.inDays} days ago";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Devices"),
        actions: [
          IconButton(
            onPressed: loadDevice,
            tooltip: 'Refresh now',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : device == null
          ? const Center(child: Text("Unable to connect to backend."))
          : ListView(
              padding: const EdgeInsets.all(16),

              children: [
                Card(
                  elevation: 4,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(18),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.memory,
                              color: Colors.blue,
                              size: 34,
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                device!.deviceName,

                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),

                              decoration: BoxDecoration(
                                color: device!.connected
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,

                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: Text(
                                device!.connected ? "ONLINE" : "OFFLINE",

                                style: TextStyle(
                                  color: device!.connected
                                      ? Colors.green
                                      : Colors.red,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 30),

                        ListTile(
                          leading: const Icon(Icons.router),
                          title: const Text("IP Address"),
                          subtitle: Text(device!.ipAddress),
                        ),

                        ListTile(
                          leading: const Icon(Icons.wifi),
                          title: const Text("Wi-Fi"),
                          subtitle: Text(device!.wifiName),
                        ),

                        ListTile(
                          leading: const Icon(Icons.update),
                          title: const Text("Firmware"),
                          subtitle: Text(device!.firmwareVersion),
                        ),

                        const ListTile(
                          leading: Icon(Icons.storage),
                          title: Text("Database"),
                          subtitle: Text("SQLite"),
                        ),

                        ListTile(
                          leading: const Icon(Icons.sensors),
                          title: const Text("Sensors"),
                          subtitle: Text(
                            "DHT22: ${device!.dht22 ? "✓" : "✗"}\n"
                            "MH-Z19C: ${device!.mhz19c ? "✓" : "✗"}\n"
                            "BME680: ${device!.bme680 ? "✓" : "✗"}",
                          ),
                        ),

                        ListTile(
                          leading: const Icon(Icons.schedule),
                          title: const Text("Last Update"),
                          subtitle: Text(
                            device!.lastUpdate == null
                                ? "No device data received yet"
                                : timeAgo(device!.lastUpdate!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
