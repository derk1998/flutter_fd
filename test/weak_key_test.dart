import 'package:flutter_fd/src/subscription/context.dart';
import 'package:flutter_fd/src/subscription/weak_key.dart';
import 'package:test/test.dart';

void main() {
  test('Verify if same when pointing to same context', () async {
    final context = Context();

    final key1 = WeakKey(WeakReference(context));
    final key2 = WeakKey(WeakReference(context));

    expect(key1, key2);
  });

  test('Verify if different when pointing to different context', () async {
    final context1 = Context();
    final context2 = Context();

    final key1 = WeakKey(WeakReference(context1));
    final key2 = WeakKey(WeakReference(context2));

    expect(key1, isNot(key2));
  });
}
