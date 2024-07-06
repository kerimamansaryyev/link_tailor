import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/integration/server_info_retriever.dart';
import 'package:link_tailor/src/app/repository/link_repository.dart';
import 'package:link_tailor/src/app/service/link_service.dart';
import 'package:link_tailor/src/app/service/result/link_service_create_link_result.dart';

@singleton
final class LinkServiceImpl implements LinkService {
  LinkServiceImpl({
    required ServerInfoRetriever serverInfoRetriever,
    required LinkRepository linkRepository,
  })  : _serverInfoRetriever = serverInfoRetriever,
        _linkRepository = linkRepository;

  final ServerInfoRetriever _serverInfoRetriever;
  final LinkRepository _linkRepository;

  @override
  Future<LinkServiceCreateLinkResult> createLink({
    required String originalUrl,
  }) {
    // TODO: implement createLink
    throw UnimplementedError();
  }
}
