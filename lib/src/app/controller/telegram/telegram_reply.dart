import 'package:link_tailor/src/app/controller/response/error_response_code.dart';
import 'package:link_tailor/src/app/controller/telegram/supported_telegram_commands.dart';

extension type const CreateLinkTelegramReply._(TelegramReplyHtmlMessage message)
    implements TelegramReplyHtmlMessage {
  CreateLinkTelegramReply(String url)
      : this._(
          TelegramReplyHtmlMessage.hyperLink(
            url,
          ),
        );
}

extension type const ErrorTelegramReply._(
        TelegramReplySimpleTextMessage message)
    implements TelegramReplySimpleTextMessage {
  ErrorTelegramReply({
    required ErrorResponseCode errorResponseCode,
  }) : this._(
          TelegramReplySimpleTextMessage(
            text: 'Error occurred. Error code: $errorResponseCode',
          ),
        );
}

sealed class TelegramReply {}

final class TelegramReplyHtmlMessage implements TelegramReply {
  const TelegramReplyHtmlMessage({
    required this.text,
  });

  factory TelegramReplyHtmlMessage.hyperLink(String url) =>
      TelegramReplyHtmlMessage(
        text: '<a href="$url">$url</a>',
      );

  final String text;
}

final class TelegramReplySimpleTextMessage implements TelegramReply {
  const TelegramReplySimpleTextMessage({
    required this.text,
  });

  factory TelegramReplySimpleTextMessage.onStart() =>
      TelegramReplySimpleTextMessage(
        text: 'Welcome to Link Tailor! To shorten your link enter: '
            '${SupportedTelegramCommand.shortenLink.displayableName} '
            '[FULL_URL]',
      );

  final String text;
}
