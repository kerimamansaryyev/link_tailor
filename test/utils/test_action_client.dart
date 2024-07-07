import 'package:orm/orm.dart';

extension type TestActionClient<T>._(ActionClient<T> actionClient)
    implements ActionClient<T> {
  TestActionClient(T result)
      : this._(
          ActionClient(
            action: 'some action',
            result: Future.value({}),
            factory: (_) => result,
          ),
        );
}
