import 'package:mockito/mockito.dart';

import '../mocks/index.mocks.dart';

MockPrismaClient generateDefaultMockPrismaClient() {
  final transactionClient = MockTransactionClient();

  final prismaClient = MockPrismaClient();

  when(prismaClient.$transaction).thenReturn(transactionClient);
  when(transactionClient.start()).thenAnswer((_) async => prismaClient);
  when(transactionClient.commit()).thenAnswer((_) async {});
  when(transactionClient.rollback()).thenAnswer((_) async {});

  return prismaClient;
}
