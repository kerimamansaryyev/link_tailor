import 'package:dotenv/dotenv.dart';

extension type AppDotEnv._(DotEnv dotEnv) implements DotEnv {
  AppDotEnv()
      : this._(
          DotEnv(
            includePlatformEnvironment: true,
          )..load(),
        );

  String? getRunMode() => this['LINK_TAILOR_RUN_MODE'];
}
