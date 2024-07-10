import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/repository/exception/link_repository_create_short_link_exception.dart';
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
    required Uri originalUri,
    required String shortenedAlias,
  }) =>
      preventConnectionLeak(
        () => launchSimpleTransaction(
          (tx) async {
            final existingByOriginalUri = await tx.link.findUnique(
              where: LinkWhereUniqueInput(
                originalUrl: originalUri.toString(),
              ),
            );
            if (existingByOriginalUri != null) {
              return (
                id: existingByOriginalUri.id!,
                originalUrl: existingByOriginalUri.originalUrl!,
                shortenedAlias: existingByOriginalUri.shortenedAlias!,
              );
            }

            final existingByAlias = await tx.link.findUnique(
              where: LinkWhereUniqueInput(
                shortenedAlias: shortenedAlias,
              ),
            );

            if (existingByAlias != null) {
              throw LinkRepositoryCreateShortLinkAliasTakenException(
                linkAlias: existingByAlias.shortenedAlias!,
              );
            }

            final created = await tx.link.create(
              data: PrismaUnion.$1(
                LinkCreateInput(
                  shortenedAlias: shortenedAlias,
                  originalUrl: originalUri.toString(),
                ),
              ),
            );
            return (
              id: created.id!,
              originalUrl: created.originalUrl!,
              shortenedAlias: created.shortenedAlias!,
            );
          },
        ),
      );
}
