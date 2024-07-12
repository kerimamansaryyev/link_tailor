import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/integration/link_url_hash_generator.dart';
import 'package:link_tailor/src/app/integration/sha_256_encryptor.dart';
import 'package:link_tailor/src/injectable_config/register_module.dart';

@Singleton(as: LinkUrlHashGenerator)
final class LinkUrlHashGeneratorImpl implements LinkUrlHashGenerator {
  LinkUrlHashGeneratorImpl(this._utf8codecFactory, this._sha256encryptor);

  final Utf8CodecFactory _utf8codecFactory;
  final Sha256Encryptor _sha256encryptor;

  @override
  FutureOr<String> generateHash(Uri originalUri) {
    final hashed = _utf8codecFactory().encode(originalUri.toString());
    final encrypted = _sha256encryptor(hashed);

    return encrypted;
  }
}
