import 'package:link_tailor/src/app/repository/link_repository.dart';

typedef LinkServiceCreateLinkResultLinkDTO = ({
  LinkRepositoryCreateShortLinkDTO repoLinkDTO,
  Uri generatedFullUri,
});

sealed class LinkServiceCreateLinkResult {}

final class LinkServiceCreateLinkSucceeded
    implements LinkServiceCreateLinkResult {
  const LinkServiceCreateLinkSucceeded({
    required this.linkDTO,
  });

  final LinkServiceCreateLinkResultLinkDTO linkDTO;
}
