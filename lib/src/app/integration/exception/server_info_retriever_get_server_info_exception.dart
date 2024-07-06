final class ServerInfoRetrieverGetServerUriException implements Exception {
  const ServerInfoRetrieverGetServerUriException();

  @override
  String toString() {
    return '${super.toString()}: Failed to retrieve server info on boot';
  }
}
