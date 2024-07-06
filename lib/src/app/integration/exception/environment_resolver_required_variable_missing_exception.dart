final class EnvironmentResolverRequiredVariableMissingException
    implements Exception {
  const EnvironmentResolverRequiredVariableMissingException({
    required this.variableName,
  });
  final String variableName;

  @override
  String toString() {
    return 'Environment variable [$variableName] is required but could not be '
        'loaded';
  }
}
