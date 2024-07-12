import 'package:gazelle_core/gazelle_core.dart';
import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/controller/mixin/rest_controller_mixin.dart';
import 'package:link_tailor/src/app/controller/request/request.dart';
import 'package:link_tailor/src/app/controller/response/error_response_code.dart';
import 'package:link_tailor/src/app/controller/response/response.dart';
import 'package:link_tailor/src/app/controller/telegram/telegram_reply.dart';
import 'package:link_tailor/src/app/integration/telegram_bot_operator.dart';

import 'package:link_tailor/src/app/service/link_service.dart';
import 'package:link_tailor/src/app/service/result/link_service_create_link_result.dart';
import 'package:link_tailor/src/app/service/result/link_service_get_link_by_alias_result.dart';
import 'package:link_tailor/src/app/util/input_validator.dart';

final class _CreateLinkRequestWithUri {
  _CreateLinkRequestWithUri({
    required this.derivedValidUri,
  });

  final Uri derivedValidUri;
}

@singleton
final class LinkController with RestControllerMixin {
  LinkController(this._linkService);

  final LinkService _linkService;

  InputValidator<String, String?> _extractValidAliasFromString() =>
      InputValidator(
        validatorName: getLinkByAliasPathParameterName,
        expectDelegate: (raw) => raw != null && raw.isNotEmpty ? raw : null,
      );

  Future<GazelleResponse<dynamic>> redirectToOriginalByAlias(
    GazelleContext context,
    GazelleRequest request,
    GazelleResponse<dynamic> _,
  ) async {
    try {
      final extractedAlias = _extractValidAliasFromString().expectDangerously(
        request.pathParameters[getLinkByAliasPathParameterName],
      );

      return switch (await _linkService.getLinkByAlias(alias: extractedAlias)) {
        LinkServiceGetLinkByAliasSucceeded(link: final link) =>
          LinkAliasRedirectResponse(
            link.originalUrlParsed,
          ),
        LinkServiceGetLinkByAliasDoesNotExist() => const GazelleResponse(
            statusCode: GazelleHttpStatusCode.custom(404),
          ),
      };
    } on InputValidationException<dynamic> catch (_) {
      return const GazelleResponse(
        statusCode: GazelleHttpStatusCode.custom(400),
      );
    }
  }

  Future<TelegramReply> createLinkFromTelegramCommand(
    TelegramBotCommandEvent commandEvent,
  ) async {
    try {
      final extractedUrlArg =
          InputValidator.uriValidator('url_validator').expectDangerously(
        commandEvent.context.args.elementAtOrNull(0),
      );

      return switch (await _linkService.createLink(
        originalUri: extractedUrlArg,
      )) {
        LinkServiceCreateLinkSucceeded(linkDTO: final link) =>
          CreateLinkTelegramReply(link.generatedFullUri.toString()),
        LinkServiceCreateLinkFailedAliasTaken() => ErrorTelegramReply(
            errorResponseCode: ErrorResponseCode.aliasAlreadyTaken,
          ),
      };
    } on InputValidationException<dynamic> catch (exception) {
      if (exception.validatorName == 'url_validator') {
        return TelegramReplySimpleTextMessage(
          text: 'Entered url "${exception.failedInput}" is not valid url.',
        );
      }
      rethrow;
    }
  }

  Future<JsonResponseAdapter> createLink(
    GazelleContext context,
    GazelleRequest request,
    GazelleResponse<dynamic> _,
  ) async =>
      handleRequestAsJson<CreateLinkRequest, _CreateLinkRequestWithUri,
          BaseResponse>(
        context: context,
        request: request,
        requestParser: CreateLinkRequest.fromJson,
        requestTransformer: (requestParsed) => _CreateLinkRequestWithUri(
          derivedValidUri:
              InputValidator.uriValidator('originalUrl').expectDangerously(
            requestParsed.data.originalUrl,
          ),
        ),
        responseDispatcher: (requestTransformed) async =>
            switch (await _linkService.createLink(
          originalUri: requestTransformed.derivedValidUri,
        )) {
          LinkServiceCreateLinkSucceeded(linkDTO: final linkDTO) =>
            JsonResponseAdapter<CreateLinkResponse>(
              body: CreateLinkResponse(
                (
                  id: linkDTO.repoLinkDTO.id,
                  shortenedAlias: linkDTO.repoLinkDTO.shortenedAlias,
                  originalUrl: linkDTO.repoLinkDTO.originalUrl,
                  shortUrl: linkDTO.generatedFullUri.toString(),
                ),
              ),
            ),
          LinkServiceCreateLinkFailedAliasTaken(
            failedAlias: final failedAlias,
          ) =>
            JsonResponseAdapter<ErrorResponse>(
              body: ErrorResponse(
                (
                  errorCode: ErrorResponseCode.aliasAlreadyTaken,
                  exceptionMessage: 'Alias $failedAlias'
                ),
              ),
            ),
        },
      );

  static const getLinkByAliasPathParameterName = 'alias';
}
