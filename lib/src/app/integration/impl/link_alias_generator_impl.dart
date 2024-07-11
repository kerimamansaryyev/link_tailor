import 'dart:async';
import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:link_tailor/src/app/integration/link_alias_generator.dart';
import 'package:link_tailor/src/app/integration/sha_256_encryptor.dart';
import 'package:link_tailor/src/injectable_config/register_module.dart';
import 'package:meta/meta.dart';

@Singleton(as: LinkAliasGenerator)
final class LinkAliasGeneratorImpl implements LinkAliasGenerator {
  LinkAliasGeneratorImpl(
    this._utfCodecFactory,
    this._sha256encryptor,
  );

  @visibleForTesting
  static const maxNumberOfCharacters = 8;
  @visibleForTesting
  static const aliasWhiteListPattern = r'^[A-HJ-NP-Z]+$';
  @visibleForTesting
  static const allowedCharacters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
    'M',
    'N',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  final Utf8CodecFactory _utfCodecFactory;
  final Sha256Encryptor _sha256encryptor;

  String _hashUrl(Uri uri) {
    final hashed = _utfCodecFactory().encode(uri.toString());
    final encrypted = _sha256encryptor(hashed);

    return encrypted;
  }

  String _filterCharacters(String character) =>
      RegExp(aliasWhiteListPattern).hasMatch(character)
          ? character
          : allowedCharacters[Random().nextInt(allowedCharacters.length)];

  String _normalizeHash(String hashedUrl) {
    return hashedUrl
        .toUpperCase()
        .substring(0, maxNumberOfCharacters)
        .split('')
        .map<String>(_filterCharacters)
        .join();
  }

  @override
  FutureOr<String> generateAlias(Uri originalUri) async => _normalizeHash(
        _hashUrl(
          originalUri,
        ),
      );
}
