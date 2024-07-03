import 'package:dotenv/dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/prisma/generated/client.dart';
import 'package:logger/logger.dart';

@singleton
class PrismaClientFactory {
  PrismaClient call() => PrismaClient();
}

@module
abstract class RegisterModule {
  @singleton
  DotEnv get dotEnv => DotEnv(includePlatformEnvironment: true)..load();

  @singleton
  Logger get logger => Logger();
}
