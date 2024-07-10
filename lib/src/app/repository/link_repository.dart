typedef LinkRepositoryCreateShortLinkDTO = ({
  String id,
  String shortenedAlias,
  String originalUrl,
});

abstract interface class LinkRepository {
  Future<LinkRepositoryCreateShortLinkDTO> createShortLink({
    required Uri originalUri,
    required String shortenedAlias,
  });
}
