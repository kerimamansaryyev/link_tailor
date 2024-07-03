typedef LinkRepositoryCreateShortLinkDTO = ({
  String shortenedAlias,
  String originalUrl,
});

abstract interface class LinkRepository {
  Future<LinkRepositoryCreateShortLinkDTO> createShortLink({
    required String originalUrl,
    required String shortenedAlias,
  });
}
