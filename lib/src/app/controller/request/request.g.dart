// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateLinkRequest _$CreateLinkRequestFromJson(Map<String, dynamic> json) =>
    CreateLinkRequest(
      _$recordConvert(
        json['data'],
        ($jsonValue) => (originalUrl: $jsonValue['originalUrl'] as String,),
      ),
    );

Map<String, dynamic> _$CreateLinkRequestToJson(CreateLinkRequest instance) =>
    <String, dynamic>{
      'data': <String, dynamic>{
        'originalUrl': instance.data.originalUrl,
      },
    };

$Rec _$recordConvert<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    convert(value as Map<String, dynamic>);
