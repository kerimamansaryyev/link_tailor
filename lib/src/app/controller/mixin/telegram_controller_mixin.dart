import 'package:link_tailor/src/app/controller/response/error_response_code.dart';
import 'package:link_tailor/src/app/controller/telegram/telegram_reply.dart';
import 'package:link_tailor/src/app/integration/telegram_bot_operator.dart';

typedef TelegramControllerCommandHandlerDelegate = Future<TelegramReply>
    Function(
  TelegramBotCommandEvent commandEvent,
);

mixin TelegramControllerMixin {
  Future<TelegramReply> handleCommand({
    required TelegramBotCommandEvent commandEvent,
    required TelegramControllerCommandHandlerDelegate replyDispatcher,
  }) async {
    try {
      return await replyDispatcher(commandEvent);
    } catch (_) {
      return ErrorTelegramReply(
        errorResponseCode: ErrorResponseCode.unexpected,
      );
    }
  }
}
