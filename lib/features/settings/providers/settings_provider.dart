import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/local/hive_service.dart';
import '../../auth/providers/auth_provider.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._hive) : super(const Locale('en')) {
    _loadFromHive();
  }

  final HiveService _hive;

  void _loadFromHive() {
    final code = _hive.loadLocale();
    if (code != null && code.isNotEmpty) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _hive.saveLocale(locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final hive = ref.read(hiveServiceProvider);
  return LocaleNotifier(hive);
});
