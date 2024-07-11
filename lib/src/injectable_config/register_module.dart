import 'dart:convert';

import 'package:dotenv/dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/util/app_dot_env.dart';
import 'package:link_tailor/src/prisma/generated/client.dart';
import 'package:logger/logger.dart';

@singleton
class PrismaClientFactory {
  PrismaClient call() => PrismaClient();
}

@singleton
class Utf8CodecFactory {
  Utf8Codec call() => utf8;
}

@module
abstract class RegisterModule {
  @singleton
  DotEnv get dotEnv => AppDotEnv();

  @singleton
  Logger get logger => Logger();
}
