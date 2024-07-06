import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/utils/app_dot_env.dart';
import 'package:link_tailor/src/injectable_config/di_init.config.dart';

extension type const AppEnvironment._(Environment environment)
    implements Environment {
  factory AppEnvironment.fromDotEnv() => switch (AppDotEnv().getRunMode()) {
        _debugKey => debug,
        _prodKey => prod,
        null || String() => debug,
      };

  static const _debugKey = 'debug';
  static const _prodKey = 'prod';

  static const debug = AppEnvironment._(Environment(_debugKey));
  static const prod = AppEnvironment._(Environment(_prodKey));
}

/// Global Service locator
final appServiceLocator = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)

/// To be called before launching the server
Future<void> configureDependencies({
  required String environment,
}) async =>
    appServiceLocator.init(
      environment: environment,
    );
