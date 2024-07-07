import 'package:dotenv/dotenv.dart';
import 'package:meta/meta.dart';

extension type AppDotEnv._(DotEnv dotEnv) implements DotEnv {
  AppDotEnv()
      : this._(
          _usedDotEnv..load(),
        );

  String? getRunMode() => this['LINK_TAILOR_RUN_MODE'];

  static DotEnv _usedDotEnv = DotEnv(
    includePlatformEnvironment: true,
  );

  /// For testing purposes,
  /// needed within setting environment prior
  /// to the app's actual
  /// Dependency Injection
  @visibleForTesting
  // ignore: use_setters_to_change_properties
  static void usedDotEnv({
    required DotEnv dotEnv,
  }) =>
      _usedDotEnv = dotEnv;
}
