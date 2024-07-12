import 'package:link_tailor/src/app/repository/link_repository.dart';

sealed class LinkServiceGetLinkByAliasResult {}

final class LinkServiceGetLinkByAliasSucceeded
    implements LinkServiceGetLinkByAliasResult {
  const LinkServiceGetLinkByAliasSucceeded({required this.link});

  final LinkRepositoryGetLinkByAliasDTO link;
}

final class LinkServiceGetLinkByAliasDoesNotExist
    implements LinkServiceGetLinkByAliasResult {
  const LinkServiceGetLinkByAliasDoesNotExist();
}
