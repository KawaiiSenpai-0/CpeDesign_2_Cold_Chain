import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppSettings settings = AppSettings.instance;
  late final TextEditingController backendController;

  @override
  void initState() {
    super.initState();
    backendController = TextEditingController(text: ApiConfig.baseUrl);
    settings.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    settings.removeListener(_refresh);
    backendController.dispose();
    super.dispose();
  }

  Future<void> saveBackendUrl() async {
    try {
      await settings.saveBackendUrl(backendController.text);
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backend saved as ${ApiConfig.baseUrl}')),
      );
    } on ArgumentError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message?.toString() ?? 'Enter a valid backend URL',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!settings.hasConfiguredBackend) ...[
            Card(
              color: Colors.amber.withValues(alpha: 0.16),
              child: const ListTile(
                leading: Icon(Icons.info_outline, color: Colors.amber),
                title: Text('Set up your backend'),
                subtitle: Text(
                  'On a physical phone, 127.0.0.1 points to the phone. '
                  'Use your computer\'s LAN URL, for example '
                  'http://192.168.1.8:8000.',
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Backend Server',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Saved on this device and used after every restart.',
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: backendController,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Backend URL',
                      hintText: 'http://192.168.1.8:8000',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cloud),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: saveBackendUrl,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Backend URL'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Card(
            child: ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh Interval'),
              subtitle: Text(
                '${settings.refreshSeconds} seconds for all screens',
              ),
              trailing: DropdownButton<int>(
                value: settings.refreshSeconds,
                items: const [
                  DropdownMenuItem(value: 5, child: Text('5 sec')),
                  DropdownMenuItem(value: 10, child: Text('10 sec')),
                  DropdownMenuItem(value: 30, child: Text('30 sec')),
                ],
                onChanged: (value) {
                  if (value != null) settings.setRefreshSeconds(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
          Card(
            child: SwitchListTile(
              value: settings.notificationsEnabled,
              onChanged: settings.setNotificationsEnabled,
              title: const Text('Notifications'),
              subtitle: const Text('Notify when produce is At Risk or Spoiled'),
              secondary: const Icon(Icons.notifications),
            ),
          ),
          const SizedBox(height: 15),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info),
              title: Text('Application'),
              subtitle: Text('ColdSense AI\nVersion 2.0'),
            ),
          ),
          const SizedBox(height: 15),
          const Card(
            child: ListTile(
              leading: Icon(Icons.people_outline),
              title: Text('Developed by'),
              subtitle: Text(
                'Jared Angelo Ringor and Kyne Foster\n'
                'University of the Cordilleras\n'
                'Computer Engineering\n'
                'jsr3509@students.uc-bcf.edu.ph',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
