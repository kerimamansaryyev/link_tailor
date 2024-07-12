import 'dart:async';

import 'package:gazelle_core/gazelle_core.dart';
import 'package:link_tailor/src/app/controller/telegram/telegram_reply.dart';
import 'package:link_tailor/src/app/integration/telegram_bot_operator.dart';
import 'package:meta/meta.dart';
import 'package:televerse/televerse.dart';

mixin TelegramAppMixin on GazelleApp {
  StreamSubscription<TelegramBotCommandEvent>? _commandEventSubs;

  Future<void> _initOperator() async {
    unawaited(_commandEventSubs?.cancel());
    _commandEventSubs =
        telegramBotOperator.onCommand().listen(_replyToCommandHandler);
    await telegramBotOperator.start();
  }

  void _closeOperator() {
    _commandEventSubs?.cancel();
    telegramBotOperator.close();
  }

  @protected
  abstract final TelegramBotOperator telegramBotOperator;

  @override
  @mustCallSuper
  Future<void> start() async {
    await super.start();
    await _initOperator();
  }

  @override
  @mustCallSuper
  Future<void> stop({bool force = false}) {
    _closeOperator();
    return super.stop(force: force);
  }

  Future<void> _replyToCommandHandler(
    TelegramBotCommandEvent commandEvent,
  ) async {
    final reply = await replyToCommand(commandEvent);

    switch (reply) {
      case TelegramReplySimpleTextMessage(text: final text):
        await commandEvent.context.reply(text);
      case TelegramReplyHtmlMessage(text: final text):
        await commandEvent.context.reply(
          text,
          parseMode: ParseMode.html,
        );
    }
  }

  Future<TelegramReply> replyToCommand(TelegramBotCommandEvent commandEvent);
}
