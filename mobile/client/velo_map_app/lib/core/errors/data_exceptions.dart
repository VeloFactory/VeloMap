class ApiException implements Exception {
  final int statusCode;
  final String? body;
  const ApiException(this.statusCode, {this.body});
}

class NetworkException implements Exception {
  const NetworkException();
}

class RequestTimeoutException implements Exception {
  const RequestTimeoutException();
}

class InvalidResponseException implements Exception {
  final String message;
  const InvalidResponseException(this.message);
}
