class ApiConfig {
  ApiConfig._();

  static String _baseUrl = 'http://127.0.0.1:8000';

  static String get baseUrl => _baseUrl;

  static void setBaseUrl(String value) {
    final normalized = value.trim().replaceFirst(RegExp(r'/$'), '');
    if (normalized.isEmpty ||
        (!normalized.startsWith('http://') &&
            !normalized.startsWith('https://'))) {
      throw ArgumentError('Enter a URL beginning with http:// or https://');
    }
    _baseUrl = normalized;
  }
}
