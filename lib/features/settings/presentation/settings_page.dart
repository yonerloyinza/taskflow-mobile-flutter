import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_mobile_flutter/core/config/backend.dart';
import 'package:taskflow_mobile_flutter/core/config/backend_store.dart';
import 'package:taskflow_mobile_flutter/core/widgets/widgets.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _customController = TextEditingController();
  bool _checking = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _select(Backend backend) {
    ref.read(backendProvider.notifier).select(backend);
    showAppSnackBar(context, 'Backend: ${backend.label}');
  }

  void _useCustom() {
    final url = _customController.text.trim();
    if (url.isEmpty) {
      return;
    }
    ref.read(backendProvider.notifier).selectCustom(url);
    showAppSnackBar(context, 'Backend personalizado: $url');
  }

  Future<void> _checkHealth() async {
    setState(() => _checking = true);
    final baseUrl = ref.read(backendProvider).baseUrl;
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );
    try {
      final response = await dio.get<dynamic>('/health');
      final ok = response.statusCode == 200;
      if (mounted) {
        showAppSnackBar(
          context,
          ok
              ? 'Conexión OK (${response.statusCode})'
              : 'Respuesta ${response.statusCode}',
          error: !ok,
        );
      }
    } catch (error) {
      if (mounted) {
        showAppSnackBar(context, 'Sin conexión: $error', error: true);
      }
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(backendProvider);
    final textTheme = Theme.of(context).textTheme;
    return AppPageScaffold(
      title: 'Ajustes',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Servidor API', style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Selecciona el backend. Al cambiar se recargan las tareas.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                for (final backend in Backend.values)
                  ListTile(
                    leading: Icon(
                      current.baseUrl == backend.baseUrl
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    title: Text(backend.label),
                    subtitle: Text(backend.baseUrl),
                    onTap: () => _select(backend),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('URL personalizada', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          AppTextField(label: 'https://...', controller: _customController),
          const SizedBox(height: 8),
          AppButton(
            label: 'Usar URL',
            type: AppButtonType.secondary,
            icon: Icons.link,
            onPressed: _useCustom,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: _checking ? 'Probando...' : 'Probar conexión',
            icon: Icons.wifi_tethering,
            onPressed: _checking ? () {} : _checkHealth,
          ),
          const SizedBox(height: 8),
          Text('Actual: ${current.baseUrl}', style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
