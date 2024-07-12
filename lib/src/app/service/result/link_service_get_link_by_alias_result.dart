import 'package:link_tailor/src/app/repository/link_repository.dart';

typedef LinkServiceGetLinkByAliasLinkDTO = ({
  LinkRepositoryGetLinkByAliasDTO repoEntity,
  Uri originalUrlParsed,
});

sealed class LinkServiceGetLinkByAliasResult {}

final class LinkServiceGetLinkByAliasSucceeded
    implements LinkServiceGetLinkByAliasResult {
  const LinkServiceGetLinkByAliasSucceeded({required this.link});

  final LinkServiceGetLinkByAliasLinkDTO link;
}

final class LinkServiceGetLinkByAliasDoesNotExist
    implements LinkServiceGetLinkByAliasResult {
  const LinkServiceGetLinkByAliasDoesNotExist();
}
