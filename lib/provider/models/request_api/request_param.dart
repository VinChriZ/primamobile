class DuplicateKeyException implements Exception {
  @override
  String toString() => "Target key already exists.";
}

class KeyNotFoundException implements Exception {
  @override
  String toString() => "Target key does not exist.";
}

class RequestParam {
  Map<String, dynamic> _parameters = {};

  Map<String, dynamic> get parameters => _parameters;

  RequestParam({Map<String, dynamic>? parameters}) {
    if (parameters != null) _parameters = Map.from(parameters);
  }

  void add(String key, dynamic value) {
    if (_parameters.containsKey(key)) throw DuplicateKeyException();

    _parameters = Map.from(_parameters)..addEntries({key: value}.entries);
  }

  void remove(String key, dynamic value) {
    if (!_parameters.containsKey(key)) throw KeyNotFoundException();

    _parameters = Map.from(_parameters)..remove(key);
  }

  void replace(String key, dynamic value) {
    if (!_parameters.containsKey(key)) throw KeyNotFoundException();

    _parameters = Map.from(_parameters)..[key] = value;
  }

  Map<String, dynamic> toJson() => parameters;
}
