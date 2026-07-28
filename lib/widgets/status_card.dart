import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final bool connected;
  final String deviceName;

  const StatusCard({
    super.key,
    required this.connected,
    required this.deviceName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          connected ? Icons.check_circle : Icons.cancel,
          color: connected ? Colors.green : Colors.red,
        ),
        title: Text(deviceName),
        subtitle: Text(connected ? 'Connected' : 'Disconnected'),
      ),
    );
  }
}
