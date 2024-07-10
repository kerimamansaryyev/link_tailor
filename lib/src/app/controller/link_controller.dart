import 'package:gazelle_core/gazelle_core.dart';
import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/controller/mixin/rest_controller_mixin.dart';
import 'package:link_tailor/src/app/controller/request/request.dart';
import 'package:link_tailor/src/app/controller/response/response.dart';

import 'package:link_tailor/src/app/service/link_service.dart';
import 'package:link_tailor/src/app/service/result/link_service_create_link_result.dart';
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

  Future<JsonResponseAdapter> createLink(
    GazelleContext context,
    GazelleRequest request,
    GazelleResponse<dynamic> _,
  ) async =>
      handleRequestAsJson<CreateLinkRequest, _CreateLinkRequestWithUri,
          CreateLinkResponse>(
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
          LinkServiceCreateLinkFailedAliasTaken() => throw UnimplementedError(),
        },
      );
}
