import 'package:link_tailor/src/app/util/app_dot_env.dart';
import 'package:link_tailor/src/injectable_config/di_init.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'mocks/index.mocks.dart';

void main() {
  const runModeVariableName = 'LINK_TAILOR_RUN_MODE';

  void prepareMockDotEnv(MockDotEnv mockDotEnv) {
    mockDotEnv.clear();
    when(mockDotEnv.load()).thenReturn(null);
    AppDotEnv.usedDotEnv(dotEnv: mockDotEnv);
  }

  group(
    'Pre-run environment variables availability testing',
    () {
      final mockDotEnv = MockDotEnv();

      setUp(() {
        prepareMockDotEnv(mockDotEnv);
      });

      test(
        'The run mode is available under $runModeVariableName',
        () {
          when(mockDotEnv[runModeVariableName]).thenAnswer((_) => 'prod');
          expect(AppDotEnv().getRunMode(), 'prod');
        },
      );
    },
  );
  group(
    'AppEnvironment testing',
    () {
      late final mockDotEnv = MockDotEnv();

      setUp(() {
        prepareMockDotEnv(mockDotEnv);
      });

      test('When the run mode was not provided then Environment is "debug"',
          () {
        when(mockDotEnv[runModeVariableName]).thenReturn(null);
        expect(AppEnvironment.fromDotEnv(), AppEnvironment.debug);
      });

      test(
        'When the run mode was provided as "prod" then Environment is "prod"',
        () {
          when(mockDotEnv[runModeVariableName]).thenReturn('prod');
          expect(AppEnvironment.fromDotEnv(), AppEnvironment.prod);
        },
      );

      test('When anything else was provided then Environment is "debug"', () {
        when(mockDotEnv[runModeVariableName]).thenReturn('anything234Else');
        expect(AppEnvironment.fromDotEnv(), AppEnvironment.debug);
      });
    },
  );
}
