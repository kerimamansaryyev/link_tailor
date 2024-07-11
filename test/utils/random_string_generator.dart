import 'dart:math';

String randomStringGenerator(int length) {
  const characters =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final rndInt = Random();
  final stringBuff = StringBuffer();
  for (var i = 0; i < length; i++) {
    stringBuff.write(characters[rndInt.nextInt(characters.length)]);
  }
  return stringBuff.toString();
}
