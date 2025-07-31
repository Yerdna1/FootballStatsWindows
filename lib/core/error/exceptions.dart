class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  const ServerException({
    required this.message,
    this.statusCode,
  });
  
  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException({
    required this.message,
  });
  
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  
  const CacheException({
    required this.message,
  });
  
  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;
  
  const AuthException({
    required this.message,
    this.code,
  });
  
  @override
  String toString() => 'AuthException: $message (Code: $code)';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;
  
  const ValidationException({
    required this.message,
    this.errors,
  });
  
  @override
  String toString() => 'ValidationException: $message';
}

class PermissionException implements Exception {
  final String message;
  
  const PermissionException({
    required this.message,
  });
  
  @override
  String toString() => 'PermissionException: $message';
}