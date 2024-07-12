import 'package:link_tailor/src/app/service/result/link_service_create_link_result.dart';
import 'package:link_tailor/src/app/service/result/link_service_get_link_by_alias_result.dart';

abstract interface class LinkService {
  Future<LinkServiceCreateLinkResult> createLink({
    required Uri originalUri,
  });

  Future<LinkServiceGetLinkByAliasResult> getLinkByAlias({
    required String alias,
  });
}
