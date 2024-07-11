import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';

@injectable
class Sha256Encryptor {
  String call(Uint8List utf8EncodedString) =>
      sha256.convert(utf8EncodedString).toString();
}
