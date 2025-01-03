class ProviderException implements Exception {
  final String message;
  ProviderException({this.message = "Provider exception."});

  @override
  String toString() => 'ProviderException: $message';
}

class ProviderFailureException implements Exception {
  final String message;
  ProviderFailureException({this.message = "Procedure failure."});

  @override
  String toString() => 'ProviderFailureException: $message';
}

class ProviderNoContentException implements Exception {
  final String message;
  ProviderNoContentException({this.message = "No content."});

  @override
  String toString() => 'ProviderNoContentException: $message';
}

// 400
class ProviderBadRequestException implements Exception {
  final String message;
  ProviderBadRequestException({this.message = "Bad request."});

  @override
  String toString() => 'ProviderBadRequestException: $message';
}

// 401
class ProviderUnauthorizedException implements Exception {
  final String message;
  ProviderUnauthorizedException({this.message = "Unauthorized access."});

  @override
  String toString() => 'ProviderUnauthorizedException: $message';
}

// 403
class ProviderForbiddenException implements Exception {
  final String message;
  ProviderForbiddenException({this.message = "Forbidden."});

  @override
  String toString() => 'ProviderForbiddenException: $message';
}

// 404
class ProviderNotFoundException implements Exception {
  final String message;
  ProviderNotFoundException({this.message = "Data not found."});

  @override
  String toString() => 'ProviderNotFoundException: $message';
}

class ProviderInternalServerErrorException implements Exception {
  final String message;
  ProviderInternalServerErrorException(
      {this.message = "Internal server error."});

  @override
  String toString() => 'ProviderInternalServerErrorException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException({this.message = 'Network error occurred'});

  @override
  String toString() => 'NetworkException: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException({this.message = 'Server error occurred'});

  @override
  String toString() => 'ServerException: $message';
}

class DataParsingException implements Exception {
  final String message;
  DataParsingException({this.message = 'Data parsing error occurred'});

  @override
  String toString() => 'DataParsingException: $message';
}
