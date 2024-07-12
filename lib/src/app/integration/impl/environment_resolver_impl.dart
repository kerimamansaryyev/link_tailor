import 'package:dotenv/dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/integration/environment_resolver.dart';
import 'package:link_tailor/src/app/integration/exception/environment_resolver_required_variable_missing_exception.dart';
import 'package:link_tailor/src/app/integration/exception/environment_variable_parse_exception.dart';

typedef _EnvVarParser<T> = T Function(String value);

@Singleton(as: EnvironmentResolver)
final class EnvironmentResolverImpl implements EnvironmentResolver {
  const EnvironmentResolverImpl(this._dotEnv);

  final DotEnv _dotEnv;

  static const _hostEnvVar = 'HOST';
  static const _portEnvVar = 'PORT';
  static const _telegramApiTokenEnvVar = 'TELEGRAM_API_TOKEN';

  T _getRequiredVar<T>({
    required String varName,
    required _EnvVarParser<T> parser,
  }) {
    final value = _dotEnv[varName]?.toString();
    if (value == null) {
      throw EnvironmentResolverRequiredVariableMissingException(
        variableName: varName,
      );
    }
    try {
      return parser(value);
    } catch (_) {
      throw EnvironmentVariableParseException(
        variableName: varName,
      );
    }
  }

  String _stringValueParser(String value) => value;

  int _intValueParser(String value) => int.parse(value);

  @override
  String getEnvHost() => _getRequiredVar(
        varName: _hostEnvVar,
        parser: _stringValueParser,
      );

  @override
  int getEnvPort() => _getRequiredVar(
        varName: _portEnvVar,
        parser: _intValueParser,
      );

  @override
  String getTelegramApiToken() => _getRequiredVar(
        varName: _telegramApiTokenEnvVar,
        parser: _stringValueParser,
      );
}
