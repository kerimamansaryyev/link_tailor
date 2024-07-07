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

      test('Environment is "debug" when the run mode not provided', () {
        when(mockDotEnv[runModeVariableName]).thenReturn(null);
        expect(AppEnvironment.fromDotEnv(), AppEnvironment.debug);
      });

      test('Environment is "prod" when the run mode provided as "prod"', () {
        when(mockDotEnv[runModeVariableName]).thenReturn('prod');
        expect(AppEnvironment.fromDotEnv(), AppEnvironment.prod);
      });

      test('Environment is "debug" when anything else is provided', () {
        when(mockDotEnv[runModeVariableName]).thenReturn('anything234Else');
        expect(AppEnvironment.fromDotEnv(), AppEnvironment.debug);
      });
    },
  );
}
