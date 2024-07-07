import 'package:dotenv/dotenv.dart';
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
])
// ignore: unused_import
import 'index.mocks.dart';
