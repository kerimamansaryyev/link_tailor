import 'package:get_it/get_it.dart';
import 'package:link_tailor/src/app/repository/exception/link_repository_create_short_link_exception.dart';
import 'package:link_tailor/src/app/repository/impl/link_repository_impl.dart';
import 'package:link_tailor/src/injectable_config/di_init.dart';
import 'package:link_tailor/src/injectable_config/register_module.dart';
import 'package:link_tailor/src/prisma/generated/model.dart';
import 'package:link_tailor/src/prisma/generated/prisma.dart';
import 'package:mockito/mockito.dart';
import 'package:orm/orm.dart';
import 'package:test/test.dart';

import '../../mocks/index.mocks.dart';
import '../../utils/default_mock_prisma_client_factory.dart';
import '../../utils/test_action_client.dart';

int _increasingRepoId = 0;

void main() {
  group('LinkRepository testing', () {
    final mockPrismaClientFactory = MockPrismaClientFactory();
    final mockLinkDelegate = MockLinkDelegate();
    late MockPrismaClient mockPrismaClient;
    late LinkRepositoryImpl linkRepositoryImpl;
    final getIt = GetIt.instance;

    setUpAll(() async {
      _increasingRepoId = 0;
      mockPrismaClient = generateDefaultMockPrismaClient();
      clearInteractions(mockPrismaClient);
      clearInteractions(mockPrismaClient.$transaction);
      clearInteractions(mockLinkDelegate);
      clearInteractions(mockPrismaClientFactory);
      when(mockPrismaClient.link).thenReturn(mockLinkDelegate);
      when(mockPrismaClientFactory.call()).thenReturn(mockPrismaClient);
      await appServiceLocator.reset();
      getIt.registerSingleton<PrismaClientFactory>(
        mockPrismaClientFactory,
      );
      await appServiceLocator.allReady();
      linkRepositoryImpl =
          LinkRepositoryImpl(appServiceLocator<PrismaClientFactory>());
    });

    group('Create link testing', () {
      test('When originalUri is already registered then return it', () async {
        final testOriginalUri = Uri.parse('https://google.com');
        const testShortenedAlias = 'GOOGLE';

        when(
          mockLinkDelegate.findUnique(
            where: argThat(
              predicate<LinkWhereUniqueInput>(
                (obj) => obj.originalUrl == testOriginalUri.toString(),
              ),
              named: 'where',
            ),
          ),
        ).thenAnswer(
          (_) => TestActionClient(
            Link(
              id: _increasingRepoId.toString(),
              originalUrl: testOriginalUri.toString(),
              shortenedAlias: testShortenedAlias,
            ),
          ),
        );

        final result = await linkRepositoryImpl.createShortLink(
          originalUri: testOriginalUri,
          shortenedAlias: testShortenedAlias,
        );
        final actualLink = (result.originalUrl, result.shortenedAlias);
        expect(
          actualLink,
          equals(
            (testOriginalUri.toString(), testShortenedAlias),
          ),
        );
        expect(_increasingRepoId, 0);
      });
      test(
          'When originalUri is not registered and shortenedAlias is registered '
          'then throw $LinkRepositoryCreateShortLinkAliasTakenException',
          () async {
        final testOriginalUri = Uri.parse('https://google.com');
        final testAnotherOriginalUri = Uri.parse('https://some.other.url');
        const testShortenedAlias = 'GOOGLE';

        when(
          mockLinkDelegate.findUnique(
            where: argThat(
              predicate<LinkWhereUniqueInput>(
                (obj) => obj.originalUrl == testOriginalUri.toString(),
              ),
              named: 'where',
            ),
          ),
        ).thenAnswer(
          (_) => TestActionClient(null),
        );

        when(
          mockLinkDelegate.findUnique(
            where: argThat(
              predicate<LinkWhereUniqueInput>(
                (obj) => obj.shortenedAlias == testShortenedAlias,
              ),
              named: 'where',
            ),
          ),
        ).thenAnswer(
          (_) => TestActionClient(
            Link(
              id: _increasingRepoId.toString(),
              originalUrl: testAnotherOriginalUri.toString(),
              shortenedAlias: testShortenedAlias,
            ),
          ),
        );

        await expectLater(
          linkRepositoryImpl.createShortLink(
            originalUri: testOriginalUri,
            shortenedAlias: testShortenedAlias,
          ),
          throwsA(
            predicate<LinkRepositoryCreateShortLinkAliasTakenException>(
              (obj) => obj.linkAlias == testShortenedAlias,
            ),
          ),
        );
        expect(_increasingRepoId, 0);
      });
      test(
          'When originalUri is not registered and shortenedAlias '
          'is not registered '
          'then create the link', () async {
        final testOriginalUri = Uri.parse('https://google.com');
        const testShortenedAlias = 'GOOGLE';

        when(
          mockLinkDelegate.findUnique(
            where: anyNamed('where'),
          ),
        ).thenAnswer(
          (_) => TestActionClient(null),
        );

        when(
          mockLinkDelegate.create(
            data: anyNamed('data'),
          ),
        ).thenAnswer(
          (invocation) {
            final data = invocation.namedArguments[#data]
                as PrismaUnion<LinkCreateInput, LinkUncheckedCreateInput>;

            final link = data.$1!;

            return TestActionClient(
              Link(
                id: (++_increasingRepoId).toString(),
                shortenedAlias: link.shortenedAlias,
                originalUrl: link.originalUrl,
              ),
            );
          },
        );

        final result = await linkRepositoryImpl.createShortLink(
          originalUri: testOriginalUri,
          shortenedAlias: testShortenedAlias,
        );
        final actualLink = (result.originalUrl, result.shortenedAlias);

        expect(
          actualLink,
          equals(
            (testOriginalUri.toString(), testShortenedAlias),
          ),
        );

        expect(_increasingRepoId, 1);
      });
    });
  });
}
