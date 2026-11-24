import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/config/env.dart';
import '../core/network/dio_client.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return const AppConfig(
    apiBaseUrl: Env.apiBaseUrl,
    environment: Env.environment,
  );
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  return createDio(config);
});

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
