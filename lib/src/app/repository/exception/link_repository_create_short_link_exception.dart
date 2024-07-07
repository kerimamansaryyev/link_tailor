import 'package:link_tailor/src/app/repository/exception/expected_repository_exception.dart';

sealed class LinkRepositoryCreateShortLinkException
    implements ExpectedRepositoryException {}

final class LinkRepositoryCreateShortLinkAliasTakenException
    implements LinkRepositoryCreateShortLinkException {
  const LinkRepositoryCreateShortLinkAliasTakenException({
    required this.linkAlias,
  });

  final String linkAlias;
}
