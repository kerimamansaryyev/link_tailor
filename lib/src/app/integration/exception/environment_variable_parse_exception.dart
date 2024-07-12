final class EnvironmentVariableParseException implements Exception {
  EnvironmentVariableParseException({required this.variableName});

  final String variableName;

  @override
  String toString() {
    return 'EnvironmentVariableParseException{variableName: $variableName}';
  }
}
