import 'package:gazelle_core/gazelle_core.dart';
import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/integration/environment_resolver.dart';
import 'package:link_tailor/src/app/integration/server_info_retriever.dart';
import 'package:logger/logger.dart';

@singleton
final class LinkTailorApp extends GazelleApp {
  LinkTailorApp._(
    this._serverInfoRetriever,
    this._logger, {
    required String address,
    required int port,
  }) : super(
          routes: [],
          address: address,
          port: port,
        );

  final ServerInfoRetriever _serverInfoRetriever;
  final Logger _logger;

  @override
  Future<void> start() async {
    await super.start();
    _bindServerInfo();
  }

  @FactoryMethod(preResolve: true)
  static Future<LinkTailorApp> init(
    ServerInfoRetriever serverInfoRetriever,
    EnvironmentResolver envResolver,
    Logger logger,
  ) async {
    final app = LinkTailorApp._(
      serverInfoRetriever,
      logger,
      address: envResolver.getEnvHost(),
      port: envResolver.getEnvPort(),
    );
    await app.start();
    return app;
  }

  void _bindServerInfo() {
    _serverInfoRetriever
      ..bindOnAppBoot(this)
      ..ensureInitialized();

    _logger.i(
      'Server is ready: ${_serverInfoRetriever.getServerInfo().toUri()}',
    );
  }
}
