import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/integration/link_alias_generator.dart';

@Singleton(as: LinkAliasGenerator)
final class LinkAliasGeneratorImpl implements LinkAliasGenerator {
  @override
  FutureOr<String> generateAlias(Uri originalUri) {
    // TODO: implement generateAlias
    throw UnimplementedError();
  }
}
