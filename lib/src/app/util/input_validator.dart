import 'package:meta/meta.dart';

typedef InputExpectDelegate<T, R> = T? Function(R input);

final class InputValidationException<R> implements Exception {
  InputValidationException({
    required this.failedInput,
    required this.validatorName,
  });

  final R failedInput;
  final String validatorName;

  @override
  String toString() {
    return 'InputValidationException{failedInput: $failedInput, '
        'validatorName: $validatorName}';
  }
}

final class InputValidator<T, R> {
  InputValidator({
    required this.validatorName,
    required this.expectDelegate,
  });

  final String validatorName;
  @protected
  final InputExpectDelegate<T, R> expectDelegate;

  T expectDangerously(R input) {
    final result = expectDelegate(input);
    if (result == null) {
      throw InputValidationException(
        validatorName: validatorName,
        failedInput: input,
      );
    }
    return result;
  }

  static InputValidator<Uri, String> uriValidator(String validatorName) =>
      InputValidator(
        validatorName: validatorName,
        expectDelegate: (input) {
          input = input.trim();
          if (input.isEmpty || !RegExp(uriPattern).hasMatch(input)) {
            return null;
          }
          return Uri.tryParse(input);
        },
      );

  static const uriPattern =
      r'((http|https)://)|(www.)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])+(?:\.[a-zA-Z]{2,})+(?:\/[^\s]*)?$';
}
