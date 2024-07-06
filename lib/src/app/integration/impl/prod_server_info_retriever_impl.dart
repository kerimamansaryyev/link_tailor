import 'package:gazelle_core/gazelle_core.dart';
import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/integration/mixin/base_server_info_retriever_mixin.dart';
import 'package:link_tailor/src/app/integration/server_info_retriever.dart';
import 'package:link_tailor/src/injectable_config/di_init.dart';

@Singleton(as: ServerInfoRetriever)
@AppEnvironment.prod
final class ProdServerInfoRetrieverImpl with BaseServerInfoRetrieverMixin {
  @override
  ServerInfoRetrieverServerInfoDTO selectInfoFromApp(GazelleApp app) =>
      ServerInfoRetrieverServerInfoDTO(
        hostName: app.address,
        scheme: ifPossibleHttps(app),
        port: null,
      );
}
