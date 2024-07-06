import 'package:gazelle_core/gazelle_core.dart';

final class ServerInfoRetrieverServerInfoDTO {
  ServerInfoRetrieverServerInfoDTO({
    required this.hostName,
    required this.scheme,
    required this.port,
  });

  final String hostName;
  final String scheme;
  final int? port;

  Uri toUri() => Uri(
        host: hostName,
        scheme: scheme,
        port: port,
      );
}

abstract interface class ServerInfoRetriever {
  void ensureInitialized();
  void bindOnAppBoot(GazelleApp app);
  ServerInfoRetrieverServerInfoDTO getServerInfo();
}
