import 'dart:async';

import 'package:flutter/foundation.dart';

class Debouncer {
  Debouncer({required this.duration});

  final Duration duration;

  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isPending => _timer?.isActive ?? false;
}
