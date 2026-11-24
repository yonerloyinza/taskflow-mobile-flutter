import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_mobile_flutter/core/config/backend.dart';
import 'package:taskflow_mobile_flutter/core/config/backend_store.dart';

import '../../helpers/mocks.dart';

void main() {
  test('BackendConfig.fromUrl reconoce presets', () {
    final config = BackendConfig.fromUrl('https://taskflow-api-rust.xprad.com');
    expect(config.id, 'rust');
    expect(config.isCustom, isFalse);
  });

  test('BackendConfig.fromUrl url desconocida -> custom', () {
    final config = BackendConfig.fromUrl('https://mi-servidor.local');
    expect(config.isCustom, isTrue);
    expect(config.baseUrl, 'https://mi-servidor.local');
  });

  test('BackendNotifier selecciona y persiste', () async {
    final prefs = await setupMockPreferences();
    final notifier = BackendNotifier(prefs);

    notifier.select(Backend.kotlin);

    expect(notifier.state.baseUrl, Backend.kotlin.baseUrl);
    final reopened = BackendNotifier(prefs);
    expect(reopened.state.id, 'kotlin');
  });

  test('BackendNotifier URL personalizada', () async {
    final prefs = await setupMockPreferences();
    final notifier = BackendNotifier(prefs);

    notifier.selectCustom('https://custom.local');

    expect(notifier.state.isCustom, isTrue);
    expect(notifier.state.baseUrl, 'https://custom.local');
  });
}
