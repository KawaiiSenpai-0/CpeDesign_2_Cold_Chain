class DeviceInfo {
  final String deviceName;
  final String ipAddress;
  final String wifiName;
  final String firmwareVersion;

  final bool connected;

  final bool dht22;

  final bool mhz19c;

  final bool bme680;

  final DateTime? lastUpdate;

  DeviceInfo({
    required this.deviceName,
    required this.ipAddress,
    required this.wifiName,
    required this.firmwareVersion,
    required this.connected,
    required this.dht22,
    required this.mhz19c,
    required this.bme680,
    required this.lastUpdate,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    final lastUpdate = json["last_update"] as String?;
    return DeviceInfo(
      deviceName: json["device_name"] as String,
      ipAddress: json["ip_address"] as String,
      wifiName: json["wifi_name"] as String,
      firmwareVersion: json["firmware_version"] as String,
      connected: json["connected"] as bool,
      dht22: json["dht22"] as bool,
      mhz19c: json["mhz19c"] as bool,
      bme680: json["bme680"] as bool,
      lastUpdate: lastUpdate == null ? null : DateTime.parse(lastUpdate),
    );
  }
}
