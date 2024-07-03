import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/repository/link_repository.dart';
import 'package:link_tailor/src/app/repository/mixin/base_repository_mixin.dart';
import 'package:link_tailor/src/injectable_config/register_module.dart';
import 'package:link_tailor/src/prisma/generated/prisma.dart';
import 'package:meta/meta.dart';
import 'package:orm/orm.dart';

@Singleton(as: LinkRepository)
final class LinkRepositoryImpl
    with BaseRepositoryMixin
    implements LinkRepository {
  LinkRepositoryImpl(
    this.prismaClientFactory,
  );

  @override
  @protected
  final PrismaClientFactory prismaClientFactory;

  @override
  Future<LinkRepositoryCreateShortLinkDTO> createShortLink({
    required String originalUrl,
    required String shortenedAlias,
  }) =>
      preventConnectionLeak(
        () => launchSimpleTransaction(
          (tx) async {
            final existing = await tx.link.findUnique(
              where: LinkWhereUniqueInput(
                originalUrl: originalUrl,
              ),
            );
            if (existing != null) {
              return (
                originalUrl: existing.originalUrl!,
                shortenedAlias: existing.shortenedAlias!,
              );
            }
            final created = await tx.link.create(
              data: PrismaUnion.$1(
                LinkCreateInput(
                  shortenedAlias: shortenedAlias,
                  originalUrl: originalUrl,
                ),
              ),
            );
            return (
              originalUrl: created.originalUrl!,
              shortenedAlias: created.shortenedAlias!,
            );
          },
        ),
      );
}
