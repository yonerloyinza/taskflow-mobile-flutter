enum Backend {
  nestjs('NestJS', 'https://taskflow-api-nest.xprad.com'),
  springboot('Spring Boot', 'https://taskflow-api-springboot.xprad.com'),
  go('Go', 'https://taskflow-api-go.xprad.com'),
  fastapi('FastAPI', 'https://taskflow-api-fastapi.xprad.com'),
  fastify('Fastify', 'https://taskflow-api-fastify.xprad.com'),
  dotnet('.NET', 'https://taskflow-api-dotnet.xprad.com'),
  rust('Rust', 'https://taskflow-api-rust.xprad.com'),
  kotlin('Kotlin', 'https://taskflow-api-kotlin.xprad.com');

  const Backend(this.label, this.baseUrl);

  final String label;
  final String baseUrl;
}

class BackendConfig {
  const BackendConfig({
    required this.id,
    required this.name,
    required this.baseUrl,
  });

  final String id;
  final String name;
  final String baseUrl;

  bool get isCustom => id == 'custom';

  static BackendConfig fromBackend(Backend backend) {
    return BackendConfig(
      id: backend.name,
      name: backend.label,
      baseUrl: backend.baseUrl,
    );
  }

  static BackendConfig fromUrl(String url) {
    for (final backend in Backend.values) {
      if (backend.baseUrl == url) {
        return fromBackend(backend);
      }
    }
    return BackendConfig(id: 'custom', name: 'Personalizado', baseUrl: url);
  }
}
