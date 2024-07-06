import 'package:dotenv/dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/integration/environment_resolver.dart';
import 'package:link_tailor/src/app/integration/exception/environment_resolver_required_variable_missing_exception.dart';

@Singleton(as: EnvironmentResolver)
final class EnvironmentResolverImpl implements EnvironmentResolver {
  const EnvironmentResolverImpl(this._dotEnv);

  final DotEnv _dotEnv;

  static const _hostEnvVar = 'HOST';
  static const _portEnvVar = 'PORT';

  @override
  String getEnvHost() {
    final host = _dotEnv[_hostEnvVar]?.toString();
    if (host == null) {
      throw const EnvironmentResolverRequiredVariableMissingException(
        variableName: _hostEnvVar,
      );
    }
    return host;
  }

  @override
  int getEnvPort() {
    final port = int.tryParse('${_dotEnv[_portEnvVar]}');
    if (port == null) {
      throw const EnvironmentResolverRequiredVariableMissingException(
        variableName: _portEnvVar,
      );
    }
    return port;
  }
}
