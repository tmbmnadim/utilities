class ServerException implements Exception {
  final int code;
  final String? message;
  final Object? error;
  ServerException({
    required this.code,
    required this.message,
    required this.error,
  });
}