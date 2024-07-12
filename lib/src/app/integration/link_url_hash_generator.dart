import 'dart:async';

abstract interface class LinkUrlHashGenerator {
  FutureOr<String> generateHash(
    Uri originalUri,
  );
}
