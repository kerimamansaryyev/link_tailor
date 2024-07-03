import 'package:gazelle_core/gazelle_core.dart';

GazelleResponse helloGazelleGet(
  GazelleContext context,
  GazelleRequest request,
  GazelleResponse response,
) {
  return GazelleResponse(
    statusCode: GazelleHttpStatusCode.success.ok_200,
    body: "Hello, World!",
  );
}
