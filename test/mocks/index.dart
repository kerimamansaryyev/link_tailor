import 'package:dotenv/dotenv.dart';
import 'package:link_tailor/src/app/integration/link_alias_generator.dart';
import 'package:link_tailor/src/app/integration/server_info_retriever.dart';
import 'package:link_tailor/src/app/integration/sha_256_encryptor.dart';
import 'package:link_tailor/src/app/repository/link_repository.dart';
import 'package:link_tailor/src/injectable_config/register_module.dart';
import 'package:link_tailor/src/prisma/generated/client.dart';
import 'package:mockito/annotations.dart';
import 'package:orm/orm.dart';

@GenerateNiceMocks([
  MockSpec<DotEnv>(),
  MockSpec<PrismaClient>(),
  MockSpec<PrismaClientFactory>(),
  MockSpec<TransactionClient<PrismaClient>>(),
  MockSpec<LinkDelegate>(),
  MockSpec<ServerInfoRetriever>(),
  MockSpec<LinkRepository>(),
  MockSpec<LinkAliasGenerator>(),
  MockSpec<Sha256Encryptor>(),
  MockSpec<Utf8CodecFactory>(),
])
// ignore: unused_import
import 'index.mocks.dart';
