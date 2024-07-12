import 'package:gazelle_core/gazelle_core.dart';
import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/controller/link_controller.dart';
import 'package:link_tailor/src/app/controller/telegram/supported_telegram_commands.dart';
import 'package:link_tailor/src/app/controller/telegram/telegram_reply.dart';
import 'package:link_tailor/src/app/integration/environment_resolver.dart';
import 'package:link_tailor/src/app/integration/mixin/telegram_app_mixin.dart';
import 'package:link_tailor/src/app/integration/server_info_retriever.dart';
import 'package:link_tailor/src/app/integration/telegram_bot_operator.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

@singleton
final class LinkTailorApp extends GazelleApp with TelegramAppMixin {
  LinkTailorApp._(
    this._linkController,
    this.telegramBotOperator,
    this._serverInfoRetriever,
    this._logger, {
    required super.address,
    required super.port,
  }) : super(
          routes: [
            GazelleRoute.parameter(
              name: LinkController.getLinkByAliasPathParameterName,
              get: _linkController.redirectToOriginalByAlias,
            ),
            GazelleRoute(
              name: 'api',
              children: [
                GazelleRoute(
                  name: 'link',
                  post: _linkController.createLink,
                ),
              ],
            ),
          ],
        );

  final ServerInfoRetriever _serverInfoRetriever;
  final Logger _logger;
  final LinkController _linkController;
  @override
  @protected
  final TelegramBotOperator telegramBotOperator;

  @override
  Future<void> start() async {
    await super.start();
    _bindServerInfo();
  }

  @FactoryMethod(preResolve: true)
  static Future<LinkTailorApp> init(
    ServerInfoRetriever serverInfoRetriever,
    TelegramBotOperator telegramBotOperator,
    EnvironmentResolver envResolver,
    Logger logger,
    LinkController linkController,
  ) async {
    final app = LinkTailorApp._(
      linkController,
      telegramBotOperator,
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

  @override
  Future<TelegramReply> replyToCommand(
    TelegramBotCommandEvent commandEvent,
  ) async =>
      switch (commandEvent.command) {
        SupportedTelegramCommand.start =>
          TelegramReplySimpleTextMessage.onStart(),
        SupportedTelegramCommand.shortenLink =>
          _linkController.createLinkFromTelegramCommand(commandEvent),
      };
}
