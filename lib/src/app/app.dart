import 'package:gazelle_core/gazelle_core.dart';
import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/controller/link_controller.dart';
import 'package:link_tailor/src/app/integration/environment_resolver.dart';
import 'package:link_tailor/src/app/integration/server_info_retriever.dart';
import 'package:logger/logger.dart';

@singleton
final class LinkTailorApp extends GazelleApp {
  LinkTailorApp._(
    LinkController linkController,
    this._serverInfoRetriever,
    this._logger, {
    required super.address,
    required super.port,
  }) : super(
          routes: [
            GazelleRoute(
              name: 'api',
              children: [
                GazelleRoute(
                  name: 'link',
                  post: linkController.createLink,
                ),
              ],
            ),
          ],
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
    LinkController linkController,
  ) async {
    final app = LinkTailorApp._(
      linkController,
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
