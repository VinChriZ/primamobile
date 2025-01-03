class ProviderException implements Exception {
  final String message = "Provider exception.";
}

class ProviderFailureException implements Exception {
  final String message;

  ProviderFailureException({this.message = "Procedure failure."});
}

class ProviderNoContentException implements Exception {
  final String message = "No content.";
}

// 400
class ProviderBadRequestException implements Exception {
  final String message = "Bad request.";
}

// 401
class ProviderUnauthorizedException implements Exception {
  final String message = "Unauthorized access.";
}

// 403
class ProviderForbiddenException implements Exception {
  final String message = "Forbidden.";
}

// 404
class ProviderNotFoundException implements Exception {
  final String message = "Data not found.";
}

class ProviderInternalServerErrorException implements Exception {
  final String message = "Internal server error.";
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network error occurred']);

  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error occurred']);

  @override
  String toString() => message;
}

class DataParsingException implements Exception {
  final String message;
  DataParsingException([this.message = 'Data parsing error occurred']);

  @override
  String toString() => message;
}
