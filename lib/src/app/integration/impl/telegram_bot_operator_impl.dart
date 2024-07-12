import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/controller/telegram/supported_telegram_commands.dart';
import 'package:link_tailor/src/app/integration/environment_resolver.dart';
import 'package:link_tailor/src/app/integration/telegram_bot_operator.dart';
import 'package:logger/logger.dart';
import 'package:televerse/televerse.dart';

@Singleton(as: TelegramBotOperator)
final class TelegramBotOperatorImpl implements TelegramBotOperator {
  @factoryMethod
  factory TelegramBotOperatorImpl.init(
    EnvironmentResolver environmentResolver,
    Logger logger,
  ) {
    final operatorBot = TelegramBotOperatorImpl._(
      Bot(
        environmentResolver.getTelegramApiToken(),
        timeout: const Duration(seconds: 5),
      ),
      logger,
    );
    return operatorBot;
  }
  TelegramBotOperatorImpl._(
    this._bot,
    this._logger,
  );

  final StreamController<TelegramBotCommandEvent> _streamController =
      StreamController.broadcast();
  final Bot _bot;
  final Logger _logger;

  @override
  Stream<TelegramBotCommandEvent> onCommand() => _streamController.stream;

  void _addSupportForCommand(SupportedTelegramCommand command) {
    _bot.command(
      command.getPatternCasted(),
      (ctx) {
        _streamController.add(
          TelegramBotCommandEvent(
            command: command,
            context: ctx,
          ),
        );
      },
    );
  }

  @override
  Future<void> start() async {
    SupportedTelegramCommand.values.forEach(_addSupportForCommand);
    unawaited(
      _bot.start().catchError(
            (dynamic exception, stack) =>
                _logger.f('Failed to start the bot. Exception: $exception'),
          ),
    );
  }

  @override
  void close() {
    _streamController.close();
    _bot.stop();
  }
}
