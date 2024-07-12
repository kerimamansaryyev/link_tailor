typedef LinkRepositoryCreateShortLinkDTO = ({
  String id,
  String shortenedAlias,
  String originalUrl,
});

typedef LinkRepositoryGetLinkByAliasDTO = ({
  String id,
  String originalUrl,
});

abstract interface class LinkRepository {
  Future<LinkRepositoryCreateShortLinkDTO> createShortLink({
    required Uri originalUri,
    required String originalUrlHash,
    required String shortenedAlias,
  });

  Future<LinkRepositoryGetLinkByAliasDTO?> getShortLinkByAlias({
    required String alias,
  });
}
