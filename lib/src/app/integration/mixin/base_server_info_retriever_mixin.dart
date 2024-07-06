import 'package:gazelle_core/gazelle_core.dart';
import 'package:link_tailor/src/app/integration/exception/server_info_retriever_get_server_info_exception.dart';
import 'package:link_tailor/src/app/integration/server_info_retriever.dart';
import 'package:meta/meta.dart';

abstract mixin class BaseServerInfoRetrieverMixin
    implements ServerInfoRetriever {
  ServerInfoRetrieverServerInfoDTO? _currentServerInfo;

  @protected
  String ifPossibleHttps(GazelleApp app) =>
      app.sslCertificate == null ? 'http' : 'https';

  @protected
  ServerInfoRetrieverServerInfoDTO selectInfoFromApp(
    GazelleApp app,
  );

  @override
  void bindOnAppBoot(GazelleApp app) {
    _currentServerInfo = selectInfoFromApp(app);
  }

  @override
  ServerInfoRetrieverServerInfoDTO getServerInfo() {
    final info = _currentServerInfo;

    if (info == null) {
      throw const ServerInfoRetrieverGetServerUriException();
    }

    return info;
  }

  @override
  void ensureInitialized() => getServerInfo();
}
