import 'package:link_tailor/src/app/service/result/link_service_create_link_result.dart';

abstract interface class LinkService {
  Future<LinkServiceCreateLinkResult> createLink({
    required String originalUrl,
  });
}
