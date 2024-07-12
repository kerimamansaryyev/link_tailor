import 'package:get_it/get_it.dart';
import 'package:link_tailor/src/app/integration/link_alias_generator.dart';
import 'package:link_tailor/src/app/integration/server_info_retriever.dart';
import 'package:link_tailor/src/app/repository/exception/link_repository_create_short_link_exception.dart';
import 'package:link_tailor/src/app/repository/link_repository.dart';
import 'package:link_tailor/src/app/service/impl/link_service_impl.dart';
import 'package:link_tailor/src/app/service/link_service.dart';
import 'package:link_tailor/src/app/service/result/link_service_create_link_result.dart';
import 'package:link_tailor/src/app/service/result/link_service_get_link_by_alias_result.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mocks/index.mocks.dart';

int _increasingLinkRepoId = 0;

typedef _CreateLinkRepeatTestCase = ({
  String testCaseName,
  void Function({
    required int throwUntil,
  }) injectMock,
  int throwUntilNumber,
  Matcher repoCallMatcher,
  Matcher aliasGeneratorMatcher,
  void Function() verifyServerInfoCall,
  Matcher resultMatcher,
});

final class _UnexpectedException implements Exception {}

Future<LinkRepositoryCreateShortLinkDTO> _defaultCreateLinkAnswer(
  Invocation invocation,
) async =>
    (
      id: (++_increasingLinkRepoId).toString(),
      originalUrl: (invocation.namedArguments[#originalUri] as Uri).toString(),
      shortenedAlias: invocation.namedArguments[#shortenedAlias] as String,
    );

void main() {
  group(
    'LinkService testing',
    () {
      late final logger = Logger();
      late LinkService linkServiceImpl;
      final mockLinkRepo = MockLinkRepository();
      final mockServerInfoRetriever = MockServerInfoRetriever();
      final mockLinkAliasGenerator = MockLinkAliasGenerator();
      final getIt = GetIt.instance;

      setUp(() async {
        _increasingLinkRepoId = 0;
        clearInteractions(mockLinkRepo);
        clearInteractions(mockServerInfoRetriever);
        clearInteractions(mockLinkAliasGenerator);
        await getIt.reset();
        getIt.registerSingleton<LinkService>(
          LinkServiceImpl(
            mockServerInfoRetriever,
            mockLinkRepo,
            mockLinkAliasGenerator,
          ),
        );
        await getIt.allReady();
        linkServiceImpl = getIt<LinkService>();
      });

      group(
        'Get Link By alias testing',
        () {
          final (testScheme, testServerHost, testPort) =
              ('http', 'google', 8080);
          final testServerInfoDTO = ServerInfoRetrieverServerInfoDTO(
            hostName: testServerHost,
            scheme: testScheme,
            port: testPort,
          );

          setUp(() {
            provideDummy<ServerInfoRetrieverServerInfoDTO>(testServerInfoDTO);
            when(mockServerInfoRetriever.getServerInfo())
                .thenReturn(testServerInfoDTO);
          });

          test(
            'When finds the link by alias, '
            'then return the $LinkServiceGetLinkByAliasSucceeded, '
            'else return $LinkServiceGetLinkByAliasDoesNotExist',
            () {
              const existing = (
                id: '1',
                alias: 'existing',
                expectedUrl: 'https://google.com',
              );
              const nonExisting = (
                id: '2',
                alias: 'nonExisting',
                expectedUrl: 'https://saddness.com',
              );

              when(
                mockLinkRepo.getShortLinkByAlias(
                  alias: existing.alias,
                ),
              ).thenAnswer(
                (_) async => (
                  id: existing.id,
                  originalUrl: existing.expectedUrl,
                ),
              );

              when(
                mockLinkRepo.getShortLinkByAlias(
                  alias: nonExisting.alias,
                ),
              ).thenAnswer(
                (_) async => null,
              );

              expectLater(
                linkServiceImpl.getLinkByAlias(alias: existing.alias),
                completion(
                  predicate<LinkServiceGetLinkByAliasSucceeded>(
                    (obj) =>
                        obj.link.repoEntity.id == existing.id &&
                        obj.link.originalUrlParsed ==
                            Uri.parse(existing.expectedUrl),
                  ),
                ),
              );
              expectLater(
                linkServiceImpl.getLinkByAlias(alias: nonExisting.alias),
                completion(
                  isA<LinkServiceGetLinkByAliasDoesNotExist>(),
                ),
              );
            },
          );
        },
      );

      group(
        'Create Link testing',
        () {
          final (testScheme, testServerHost, testPort) =
              ('http', 'google', 8080);
          const testAlias = 'randomAlias';
          final testServerInfoDTO = ServerInfoRetrieverServerInfoDTO(
            hostName: testServerHost,
            scheme: testScheme,
            port: testPort,
          );

          setUp(() {
            provideDummy<ServerInfoRetrieverServerInfoDTO>(testServerInfoDTO);

            when(mockLinkAliasGenerator.generateAlias(argThat(isNotNull)))
                .thenAnswer(
              (inv) async => testAlias,
            );
            when(mockServerInfoRetriever.getServerInfo())
                .thenReturn(testServerInfoDTO);
          });

          test(
            'When there is no exception '
            'then return $LinkServiceCreateLinkSucceeded '
            'with matching server info',
            () async {
              when(
                mockLinkRepo.createShortLink(
                  originalUri: argThat(isNotNull, named: 'originalUri'),
                  shortenedAlias: argThat(isNotNull, named: 'shortenedAlias'),
                ),
              ).thenAnswer(_defaultCreateLinkAnswer);

              final expectedOriginalUri = Uri.parse('https://netflix.com');
              final expectedResultUri = Uri.parse(
                '$testScheme://$testServerHost:$testPort/$testAlias',
              );
              final expectedLinkRepoDTO = (
                id: (_increasingLinkRepoId + 1).toString(),
                originalUrl: expectedOriginalUri.toString(),
                shortenedAlias: testAlias,
              );

              final result = await linkServiceImpl.createLink(
                originalUri: Uri.parse('https://netflix.com'),
              );

              expect(
                result,
                predicate<LinkServiceCreateLinkResult>(
                  (obj) => switch (obj) {
                    LinkServiceCreateLinkSucceeded(linkDTO: final linkDTO) =>
                      linkDTO.repoLinkDTO == expectedLinkRepoDTO &&
                          linkDTO.generatedFullUri.toString() ==
                              expectedResultUri.toString(),
                    _ => false,
                  },
                ),
              );
            },
          );

          test(
            'When $LinkRepositoryCreateShortLinkAliasTakenException is thrown '
            'then generation process will be repeated up to '
            '${LinkServiceImpl.maxNumberOfAliasGenerateRetries} times '
            "ending with $LinkServiceCreateLinkFailedAliasTaken if can't "
            'make it to success',
            () async {
              void throwRepoExceptionUnlessReachesThrowUntil({
                required int throwUntil,
              }) {
                var repeatNumber = 0;

                when(
                  mockLinkRepo.createShortLink(
                    originalUri: argThat(isNotNull, named: 'originalUri'),
                    shortenedAlias: argThat(isNotNull, named: 'shortenedAlias'),
                  ),
                ).thenAnswer(
                  (invocation) async => ++repeatNumber < throwUntil
                      ? throw LinkRepositoryCreateShortLinkAliasTakenException(
                          linkAlias: invocation.namedArguments[#shortenedAlias]
                              as String,
                        )
                      : _defaultCreateLinkAnswer(invocation),
                );
              }

              final cases = <_CreateLinkRepeatTestCase>[
                (
                  testCaseName: 'Simple test case',
                  throwUntilNumber: 4,
                  repoCallMatcher: equals(4),
                  aliasGeneratorMatcher: equals(4),
                  verifyServerInfoCall: () =>
                      verify(mockServerInfoRetriever.getServerInfo()).called(1),
                  resultMatcher: completion(
                    isA<LinkServiceCreateLinkSucceeded>(),
                  ),
                  injectMock: throwRepoExceptionUnlessReachesThrowUntil,
                ),
                (
                  testCaseName: 'Edge case when repeating till '
                      '${LinkServiceImpl.maxNumberOfAliasGenerateRetries} ',
                  throwUntilNumber:
                      LinkServiceImpl.maxNumberOfAliasGenerateRetries,
                  repoCallMatcher:
                      equals(LinkServiceImpl.maxNumberOfAliasGenerateRetries),
                  aliasGeneratorMatcher:
                      equals(LinkServiceImpl.maxNumberOfAliasGenerateRetries),
                  verifyServerInfoCall: () =>
                      verify(mockServerInfoRetriever.getServerInfo()).called(1),
                  resultMatcher: completion(
                    isA<LinkServiceCreateLinkSucceeded>(),
                  ),
                  injectMock: throwRepoExceptionUnlessReachesThrowUntil,
                ),
                (
                  testCaseName: 'Edge '
                      'case when trying '
                      'to exceed number of repeats '
                      '${LinkServiceImpl.maxNumberOfAliasGenerateRetries}',
                  throwUntilNumber:
                      LinkServiceImpl.maxNumberOfAliasGenerateRetries + 1,
                  repoCallMatcher:
                      equals(LinkServiceImpl.maxNumberOfAliasGenerateRetries),
                  aliasGeneratorMatcher:
                      equals(LinkServiceImpl.maxNumberOfAliasGenerateRetries),
                  verifyServerInfoCall: () =>
                      verifyNever(mockServerInfoRetriever.getServerInfo())
                          .called(0),
                  resultMatcher: completion(
                    isA<LinkServiceCreateLinkFailedAliasTaken>(),
                  ),
                  injectMock: throwRepoExceptionUnlessReachesThrowUntil,
                ),
              ];

              for (final testCase in cases) {
                try {
                  testCase.injectMock(
                    throwUntil: testCase.throwUntilNumber,
                  );

                  final testUri = Uri.parse('https://netflix.com');

                  await expectLater(
                    linkServiceImpl.createLink(
                      originalUri: testUri,
                    ),
                    testCase.resultMatcher,
                  );

                  verify(
                    mockLinkAliasGenerator.generateAlias(testUri),
                  ).called(testCase.aliasGeneratorMatcher);
                  verify(
                    mockLinkRepo.createShortLink(
                      originalUri: testUri,
                      shortenedAlias: testAlias,
                    ),
                  ).called(testCase.repoCallMatcher);

                  testCase.verifyServerInfoCall();
                } catch (_) {
                  logger.f('Failed test case: ${testCase.testCaseName}');
                  rethrow;
                }
              }
              expect(_increasingLinkRepoId, 2);
            },
          );
          test(
            'When unexpected exception is thrown by $LinkAliasGenerator '
            'component '
            'then escape immediately',
            () {
              when(mockLinkAliasGenerator.generateAlias(any))
                  .thenAnswer((_) => throw _UnexpectedException());
              expectLater(
                linkServiceImpl.createLink(
                  originalUri: Uri.parse('https://netflix.com'),
                ),
                throwsA(isA<_UnexpectedException>()),
              );
            },
          );
          test(
            'When unexpected exception is thrown by $LinkRepository '
            'component '
            'then escape immediately',
            () {
              when(
                mockLinkRepo.createShortLink(
                  originalUri: anyNamed('originalUri'),
                  shortenedAlias: anyNamed('shortenedAlias'),
                ),
              ).thenAnswer((_) => throw _UnexpectedException());
              expectLater(
                linkServiceImpl.createLink(
                  originalUri: Uri.parse('https://netflix.com'),
                ),
                throwsA(isA<_UnexpectedException>()),
              );
            },
          );
          test(
            'When unexpected exception is thrown by $ServerInfoRetriever '
            'component '
            'then escape immediately',
            () {
              when(
                mockLinkRepo.createShortLink(
                  originalUri: argThat(isNotNull, named: 'originalUri'),
                  shortenedAlias: argThat(isNotNull, named: 'shortenedAlias'),
                ),
              ).thenAnswer(_defaultCreateLinkAnswer);
              when(
                mockServerInfoRetriever.getServerInfo(),
              ).thenAnswer((_) => throw _UnexpectedException());
              expectLater(
                linkServiceImpl.createLink(
                  originalUri: Uri.parse('https://netflix.com'),
                ),
                throwsA(isA<_UnexpectedException>()),
              );
            },
          );
        },
      );
    },
  );
}
