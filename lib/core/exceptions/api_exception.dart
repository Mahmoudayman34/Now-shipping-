class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? response;

  ApiException({
    required this.message,
    this.statusCode,
    this.response,
  });

  @override
  String toString() {
    return 'ApiException: $message ${statusCode != null ? '(Status: $statusCode)' : ''}';
  }
}
