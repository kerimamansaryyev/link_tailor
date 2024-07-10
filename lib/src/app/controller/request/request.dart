import 'dart:async';
import 'dart:convert';

import 'package:gazelle_core/gazelle_core.dart';
import 'package:json_annotation/json_annotation.dart';

part 'request.g.dart';

typedef BaseRequestJsonParserDelegate<T extends BaseRequest> = FutureOr<T>
    Function(
  Map<String, dynamic> data,
);

extension type BaseRequestGazelleRequestAdapter(GazelleRequest request) {
  Future<T> parseJsonBody<T extends BaseRequest>(
    BaseRequestJsonParserDelegate<T> parser,
  ) async {
    final decoded =
        await jsonDecode((await request.body)!) as Map<String, dynamic>;
    return await parser(decoded);
  }
}

typedef CreateLinkRequestBody = ({
  String originalUrl,
});

abstract base class BaseRequest<T extends Record> {
  BaseRequest(this.data);

  final T data;
}

@JsonSerializable()
final class CreateLinkRequest extends BaseRequest<CreateLinkRequestBody> {
  CreateLinkRequest(super.data);

  factory CreateLinkRequest.fromJson(Map<String, dynamic> data) =>
      _$CreateLinkRequestFromJson(data);
}
