import 'package:gazelle_core/gazelle_core.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:link_tailor/src/app/controller/response/error_response_code.dart';

part 'response.g.dart';

extension type JsonResponseAdapter<T extends BaseResponse>._(
        GazelleResponse<Map<String, dynamic>> data)
    implements GazelleResponse<Map<String, dynamic>> {
  JsonResponseAdapter({
    required T body,
    GazelleHttpStatusCode statusCode = const GazelleHttpStatusCode.custom(200),
    List<GazelleHttpHeader> headers = const [],
    Map<String, dynamic> metadata = const {},
  }) : this._(
          GazelleResponse(
            body: body.toJson(),
            statusCode: statusCode,
            headers: headers,
            metadata: metadata,
          ),
        );

  static JsonResponseAdapter invalidRequestFormat(
    String exceptionMessage,
  ) =>
      JsonResponseAdapter<ErrorResponse>(
        statusCode: const GazelleHttpStatusCode.custom(400),
        body: ErrorResponse(
          (
            errorCode: ErrorResponseCode.invalidRequestFormat,
            exceptionMessage: exceptionMessage,
          ),
        ),
      );

  static JsonResponseAdapter invalidInput(String inputFieldName) =>
      JsonResponseAdapter<ErrorResponse>(
        statusCode: const GazelleHttpStatusCode.custom(400),
        body: ErrorResponse(
          (
            errorCode: ErrorResponseCode.invalidInput,
            exceptionMessage: 'Invalid input: $inputFieldName',
          ),
        ),
      );

  static JsonResponseAdapter unexpected(
    dynamic exception,
  ) =>
      JsonResponseAdapter<ErrorResponse>(
        statusCode: const GazelleHttpStatusCode.custom(500),
        body: ErrorResponse(
          (
            errorCode: ErrorResponseCode.unexpected,
            exceptionMessage: exception.toString(),
          ),
        ),
      );
}

typedef ErrorResponseData = ({
  ErrorResponseCode errorCode,
  String exceptionMessage,
});

typedef CreateLinkResponseData = ({
  String id,
  String shortenedAlias,
  String shortUrl,
  String originalUrl,
});

abstract base class BaseResponse<T extends Record> {
  BaseResponse(
    this.data,
  );

  final T data;

  Map<String, dynamic> toJson();
}

@JsonSerializable()
final class ErrorResponse extends BaseResponse<ErrorResponseData> {
  ErrorResponse(super.data);

  @override
  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}

@JsonSerializable()
final class CreateLinkResponse extends BaseResponse<CreateLinkResponseData> {
  CreateLinkResponse(super.data);

  @override
  Map<String, dynamic> toJson() => _$CreateLinkResponseToJson(this);
}
