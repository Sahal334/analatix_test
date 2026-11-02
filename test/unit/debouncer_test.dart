
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:analatix_flutter_test_muhammedsahal/core/utils/debouncer.dart';

void main() {
  const delay = Duration(milliseconds: 300);

  test('action is called after the debounce delay', () {
    fakeAsync((async) {
      final debouncer = Debouncer(duration: delay);
      var callCount = 0;

      debouncer.run(() => callCount++);

      async.elapse(const Duration(milliseconds: 200));
      expect(callCount, equals(0));

      async.elapse(const Duration(milliseconds: 150));
      expect(callCount, equals(1));
    });
  });

  test('rapid successive calls → only the last one fires', () {
    fakeAsync((async) {
      final debouncer = Debouncer(duration: delay);
      var lastValue = 0;

      debouncer.run(() => lastValue = 1);
      async.elapse(const Duration(milliseconds: 100));

      debouncer.run(() => lastValue = 2);
      async.elapse(const Duration(milliseconds: 100));

      debouncer.run(() => lastValue = 3);

      async.elapse(const Duration(milliseconds: 400));

      expect(lastValue, equals(3));
    });
  });

  test('cancel prevents the pending action from firing', () {
    fakeAsync((async) {
      final debouncer = Debouncer(duration: delay);
      var called = false;

      debouncer.run(() => called = true);
      expect(debouncer.isPending, isTrue);

      debouncer.cancel();
      expect(debouncer.isPending, isFalse);

      async.elapse(const Duration(milliseconds: 500));
      expect(called, isFalse);
    });
  });

  test('isPending is true while waiting and false after firing', () {
    fakeAsync((async) {
      final debouncer = Debouncer(duration: delay);

      expect(debouncer.isPending, isFalse);
      debouncer.run(() {});
      expect(debouncer.isPending, isTrue);

      async.elapse(delay + const Duration(milliseconds: 1));
      expect(debouncer.isPending, isFalse);
    });
  });

  test('after cancel a new run fires correctly', () {
    fakeAsync((async) {
      final debouncer = Debouncer(duration: delay);
      var callCount = 0;

      debouncer.run(() => callCount++);
      debouncer.cancel();

      debouncer.run(() => callCount++);
      async.elapse(delay + const Duration(milliseconds: 1));

      expect(callCount, equals(1));
    });
  });
}
