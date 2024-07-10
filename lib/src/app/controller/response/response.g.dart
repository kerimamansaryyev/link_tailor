// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      _$recordConvert(
        json['data'],
        ($jsonValue) => (
          errorCode:
              $enumDecode(_$ErrorResponseCodeEnumMap, $jsonValue['errorCode']),
          exceptionMessage: $jsonValue['exceptionMessage'] as String,
        ),
      ),
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'data': <String, dynamic>{
        'errorCode': _$ErrorResponseCodeEnumMap[instance.data.errorCode]!,
        'exceptionMessage': instance.data.exceptionMessage,
      },
    };

const _$ErrorResponseCodeEnumMap = {
  ErrorResponseCode.aliasAlreadyTaken: 'aliasAlreadyTaken',
  ErrorResponseCode.invalidRequestFormat: 'invalidRequestFormat',
  ErrorResponseCode.invalidInput: 'invalidInput',
};

$Rec _$recordConvert<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    convert(value as Map<String, dynamic>);

CreateLinkResponse _$CreateLinkResponseFromJson(Map<String, dynamic> json) =>
    CreateLinkResponse(
      _$recordConvert(
        json['data'],
        ($jsonValue) => (
          id: $jsonValue['id'] as String,
          originalUrl: $jsonValue['originalUrl'] as String,
          shortUrl: $jsonValue['shortUrl'] as String,
          shortenedAlias: $jsonValue['shortenedAlias'] as String,
        ),
      ),
    );

Map<String, dynamic> _$CreateLinkResponseToJson(CreateLinkResponse instance) =>
    <String, dynamic>{
      'data': <String, dynamic>{
        'id': instance.data.id,
        'originalUrl': instance.data.originalUrl,
        'shortUrl': instance.data.shortUrl,
        'shortenedAlias': instance.data.shortenedAlias,
      },
    };
