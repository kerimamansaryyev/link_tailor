import 'dart:async';

abstract interface class LinkAliasGenerator {
  FutureOr<String> generateAlias(
    Uri originalUri,
  );
}
