class CacheException implements Exception {
  const CacheException({required this.message, required this.statusCode});

  final String message;
  final int statusCode;
}

class StorageException implements Exception {
  const StorageException({required this.message, required this.statusCode});

  final String message;
  final int statusCode;
}
