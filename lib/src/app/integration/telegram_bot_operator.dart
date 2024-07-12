import 'package:link_tailor/src/app/controller/telegram/supported_telegram_commands.dart';
import 'package:televerse/televerse.dart' as televerse;

final class TelegramBotCommandEvent {
  TelegramBotCommandEvent({
    required this.command,
    required this.context,
  });

  final SupportedTelegramCommand command;
  final televerse.Context context;
}

abstract interface class TelegramBotOperator {
  Stream<TelegramBotCommandEvent> onCommand();
  Future<void> start();
  void close();
}
