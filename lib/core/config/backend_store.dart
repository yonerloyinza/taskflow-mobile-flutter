import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backend.dart';
import 'env.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider debe sobrescribirse en main()',
  ),
);

class BackendNotifier extends StateNotifier<BackendConfig> {
  BackendNotifier(this._prefs)
    : super(
        BackendConfig.fromUrl(_prefs.getString(_storageKey) ?? Env.apiBaseUrl),
      );

  static const String _storageKey = 'taskflow.backend.url';

  final SharedPreferences _prefs;

  void select(Backend backend) {
    state = BackendConfig.fromBackend(backend);
    _prefs.setString(_storageKey, backend.baseUrl);
  }

  void selectCustom(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return;
    }
    state = BackendConfig.fromUrl(trimmed);
    _prefs.setString(_storageKey, trimmed);
  }
}

final backendProvider = StateNotifierProvider<BackendNotifier, BackendConfig>(
  (ref) => BackendNotifier(ref.watch(sharedPreferencesProvider)),
);
