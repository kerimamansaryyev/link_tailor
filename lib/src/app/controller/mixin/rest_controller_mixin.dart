import 'dart:async';

import 'package:gazelle_core/gazelle_core.dart';
import 'package:link_tailor/src/app/controller/request/request.dart';
import 'package:link_tailor/src/app/controller/response/response.dart';
import 'package:link_tailor/src/app/util/input_validator.dart';

typedef RestControllerMixinResponseDispatcher<T, B extends BaseResponse>
    = FutureOr<JsonResponseAdapter<B>> Function(T data);

typedef RestControllerMixinRequestTransformer<Req extends BaseRequest, T>
    = FutureOr<T> Function(
  Req requestParsed,
);

mixin RestControllerMixin {
  Future<JsonResponseAdapter> handleRequestAsJson<Req extends BaseRequest, T,
      Res extends BaseResponse>({
    required GazelleContext context,
    required GazelleRequest request,
    required BaseRequestJsonParserDelegate<Req> requestParser,
    required RestControllerMixinRequestTransformer<Req, T> requestTransformer,
    required RestControllerMixinResponseDispatcher<T, Res> responseDispatcher,
  }) async {
    T transformedRequest;

    try {
      final requestParsed =
          await BaseRequestGazelleRequestAdapter(request).parseJsonBody<Req>(
        requestParser,
      );
      transformedRequest = await requestTransformer(requestParsed);
    } on InputValidationException<dynamic> catch (ex) {
      return JsonResponseAdapter.invalidInput(
        ex.validatorName,
      );
    } catch (ex) {
      return JsonResponseAdapter.invalidRequestFormat(
        ex.toString(),
      );
    }

    return await responseDispatcher(transformedRequest);
  }
}
