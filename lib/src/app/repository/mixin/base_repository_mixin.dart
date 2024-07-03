import 'package:link_tailor/src/app/repository/exception/expected_repository_exception.dart';
import 'package:link_tailor/src/injectable_config/register_module.dart';
import 'package:link_tailor/src/prisma/generated/client.dart';
import 'package:meta/meta.dart';

typedef DatabaseAction<T> = Future<T> Function();
typedef BaseRepositoryTransactionDelegate<T> = Future<T> Function(
  PrismaClient tx,
);

mixin BaseRepositoryMixin {
  @protected
  abstract final PrismaClientFactory prismaClientFactory;

  late PrismaClient _prismaClient = prismaClientFactory();

  @protected
  Future<T> launchSimpleTransaction<T>(
    BaseRepositoryTransactionDelegate<T> transactionDelegate,
  ) async {
    final tx = await currentPrismaClient.$transaction.start();
    try {
      final result = await transactionDelegate(tx);
      await tx.$transaction.commit();
      return result;
    } catch (_) {
      await tx.$transaction.rollback();
      rethrow;
    }
  }

  @protected
  Future<T> preventConnectionLeak<T>(DatabaseAction<T> action) async {
    try {
      return await action();
    } catch (ex) {
      if (ex is! ExpectedRepositoryException) {
        await _prismaClient.$disconnect();
        _replaceClient();
      }
      rethrow;
    }
  }

  @protected
  PrismaClient get currentPrismaClient => _prismaClient;

  void _replaceClient() => _prismaClient = prismaClientFactory();
}
