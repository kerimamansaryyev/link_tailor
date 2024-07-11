import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:link_tailor/src/app/integration/impl/link_alias_generator_impl.dart';
import 'package:link_tailor/src/app/integration/link_alias_generator.dart';
import 'package:link_tailor/src/app/integration/sha_256_encryptor.dart';
import 'package:link_tailor/src/injectable_config/register_module.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mocks/index.mocks.dart';
import '../../utils/random_string_generator.dart';

void main() {
  group(
    '$LinkAliasGenerator testing',
    () {
      final logger = Logger();
      final getIt = GetIt.instance;
      final mockSha256Encryptor = MockSha256Encryptor();
      final mockUtf8CodecFactory = MockUtf8CodecFactory();
      late LinkAliasGenerator linkAliasGenerator;

      setUp(() async {
        provideDummy<Utf8Codec>(utf8);
        clearInteractions(mockUtf8CodecFactory);
        clearInteractions(mockSha256Encryptor);

        when(mockUtf8CodecFactory.call()).thenReturn(utf8);
        await getIt.reset();
        getIt
          ..registerSingleton<Utf8CodecFactory>(
            mockUtf8CodecFactory,
          )
          ..registerSingleton<Sha256Encryptor>(
            mockSha256Encryptor,
          )
          ..registerSingleton<LinkAliasGenerator>(
            LinkAliasGeneratorImpl(
              getIt(),
              getIt(),
            ),
          );
        await getIt.allReady();
        linkAliasGenerator = getIt<LinkAliasGenerator>();
      });

      group(
        'Generate alias testing',
        () {
          test(
            'Generated alias has must '
            'not be larger '
            'than ${LinkAliasGeneratorImpl.maxNumberOfCharacters} '
            'in the normalized form',
            () {
              final testUri = Uri.parse('https://google.com/some/long/link');
              final testStringUtfEncoded = utf8.encode(testUri.toString());
              final testHash = 'asd' * 36;
              final expectedHash = testHash.toUpperCase().substring(
                    0,
                    LinkAliasGeneratorImpl.maxNumberOfCharacters,
                  );

              when(
                mockSha256Encryptor.call(
                  argThat(equals(testStringUtfEncoded)),
                ),
              ).thenReturn(testHash);

              expectLater(
                linkAliasGenerator.generateAlias(testUri),
                completion(expectedHash),
              );
            },
          );
          test(
            'When disallowed characters were found, '
            'then must replace them with random element of '
            '${LinkAliasGeneratorImpl.allowedCharacters} ',
            () async {
              final testUri = Uri.parse('https://google.com/some/long/link');
              final testStringUtfEncoded = utf8.encode(testUri.toString());

              final predefinedTestCases = <String>[
                'ioio123i',
                r'afsdfj$dfskdjng',
                'oiowierodve123',
                '12345678',
              ];

              final randomTestCases = List<String>.generate(
                50,
                (_) => randomStringGenerator(
                  10,
                ),
              );

              for (final testCase in [
                ...predefinedTestCases,
                ...randomTestCases,
              ]) {
                try {
                  when(
                    mockSha256Encryptor.call(
                      argThat(equals(testStringUtfEncoded)),
                    ),
                  ).thenReturn(testCase);
                  await expectLater(
                    linkAliasGenerator.generateAlias(testUri),
                    completion(
                      predicate<String>(
                        (alias) =>
                            RegExp(LinkAliasGeneratorImpl.aliasWhiteListPattern)
                                .hasMatch(alias),
                      ),
                    ),
                  );
                } catch (_) {
                  logger.f('Failed test case: $testCase');
                }
              }
            },
          );
        },
      );
    },
  );
}
