import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/integration/link_alias_generator.dart';
import 'package:link_tailor/src/app/integration/server_info_retriever.dart';
import 'package:link_tailor/src/app/repository/exception/link_repository_create_short_link_exception.dart';
import 'package:link_tailor/src/app/repository/link_repository.dart';
import 'package:link_tailor/src/app/service/link_service.dart';
import 'package:link_tailor/src/app/service/result/link_service_create_link_result.dart';
import 'package:meta/meta.dart';

@Singleton(as: LinkService)
final class LinkServiceImpl implements LinkService {
  LinkServiceImpl(
    this._serverInfoRetriever,
    this._linkRepository,
    this._linkAliasGenerator,
  );

  @visibleForTesting
  static const maxNumberOfAliasGenerateRetries = 10;

  final ServerInfoRetriever _serverInfoRetriever;
  final LinkRepository _linkRepository;
  final LinkAliasGenerator _linkAliasGenerator;

  @override
  Future<LinkServiceCreateLinkResult> createLink({
    required Uri originalUri,
  }) async {
    var numberOfRetries = 0;
    Exception? occurredException;

    retry_loop:
    do {
      try {
        final generatedAlias = await _linkAliasGenerator.generateAlias(
          originalUri,
        );
        final createdLink = await _linkRepository.createShortLink(
          originalUri: originalUri,
          shortenedAlias: generatedAlias,
        );
        final serverInfo = _serverInfoRetriever.getServerInfo();

        return LinkServiceCreateLinkSucceeded(
          linkDTO: (
            repoLinkDTO: createdLink,
            generatedFullUri: Uri(
              scheme: serverInfo.scheme,
              host: serverInfo.hostName,
              port: serverInfo.port,
              path: '/${createdLink.shortenedAlias}',
            ),
          ),
        );
      } on LinkRepositoryCreateShortLinkException catch (ex) {
        switch (ex) {
          case LinkRepositoryCreateShortLinkAliasTakenException():
            occurredException = ex;
            continue retry_loop;
        }
      }
    } while (++numberOfRetries < maxNumberOfAliasGenerateRetries);

    switch (occurredException) {
      case LinkRepositoryCreateShortLinkAliasTakenException(
          linkAlias: final failedAlias,
        ):
        return LinkServiceCreateLinkFailedAliasTaken(
          failedAlias: failedAlias,
        );
      default:
        throw occurredException;
    }
  }
}
