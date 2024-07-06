import 'package:link_tailor/src/injectable_config/di_init.dart';

Future<void> runApp(List<String> args) async {
  await configureDependencies(
    environment: AppEnvironment.fromDotEnv().name,
  );
}
