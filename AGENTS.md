# AGENTS.md — Gobernanza de taskflow-mobile-flutter

## 1. Contexto del Repositorio
- **Proyecto:** `taskflow-mobile-flutter`
- **Stack:** Flutter 3.24+ + Dart 3.5+ + Riverpod (State) + Dio (HTTP) + Freezed (Data Classes) + Drift (SQLite) + GoRouter (Navigation) + Flutter Hooks
- **Targets:** Android, iOS, Web, Windows, macOS, Linux
- **API Contrato:** `docs/openapi.yaml` (OpenAPI 3.1) — consumido por backend taskflow-api-* via `API_BASE_URL` (`--dart-define` / `.env`)
- **Ecosistema:** Polyrepo TaskFlow (mobile Flutter, sin monorepo)
- **Variables de Entorno:** `--dart-define=API_BASE_URL=https://...` / `.env` (flutter_dotenv)
- **Build Strategy:**
  - **Web (WASM):** VPS Docker build → nginx + Traefik (CI/CD: `docker compose up -d --build web`)
  - **Android/iOS/Desktop:** **Local build required** (Flutter SDK 3.24+, Android SDK, Xcode 15+) **or** GitHub Actions / Codemagic (macOS runners for iOS)
  - **Artifacts:** APK/AAB/IPA/MSIX/DMG/AppImage uploaded to stores/releases; not built on VPS

## 2. Reglas de Ejecución (Human-in-the-Loop)
1. **Un solo paso a la vez:** Prohibido implementar múltiples pasos sin aprobación explícita.
2. **Plan Previo:** Antes de tocar archivos, muestra: objetivo, archivos exactos, comandos y mensaje de Conventional Commit.
3. **Auto-verificación:** Ejecuta linter (`flutter analyze`), format (`dart format`), tests (`flutter test`), build (`flutter build <target>`) del paso antes de entregar y muestra la salida real.
4. **Parada obligatoria:** Detente tras verificar, indica al usuario cómo probarlo y espera su visto bueno.
5. **Commit Atómico:** Tras aprobación, actualiza `docs/03-roadmap.md` y `docs/04-ai-log.md`, y ejecuta `git add` + `git commit` con Conventional Commits.

## 3. Reglas Arquitectónicas
- **Contract-First:** Tipos Dart generados desde `docs/openapi.yaml` (`openapi-generator` Dart/Flutter o `freezed` + manual) — rutas, DTOs, enums, paginación, errores sincronizados 100%.
- **Architecture:** Clean Architecture + Feature-First — `core` (shared), `features/tasks` (domain/data/presentation), `app` (DI, routing, theming).
- **State Management:** Riverpod 2.x (`StateNotifierProvider`, `AsyncValue`, `FutureProvider`, `StreamProvider`) — compile-safe, testable, scoped.
- **Networking:** Dio + `retrofit.dart` (code-gen) — interceptors (Auth, Logging, Retry, Error handling), `baseUrl` desde config.
- **Persistence:** Drift (SQLite) — type-safe queries, migrations, `NativeDatabase` (mobile/desktop), `WebDatabase` (IndexedDB), DAOs + Repository pattern.
- **Dependency Injection:** Riverpod (`ProviderScope`, `Provider`, `AutoDispose`) — no service locator, compile-time safety.
- **Navigation:** GoRouter — declarative routes, deep linking, redirects, guards, type-safe params (`GoRoute(path: '/task/:id')`).
- **Forms & Validation:** `reactive_forms` o `formz` + `freezed` DTOs — validación reactiva, sync con backend.
- **Theming:** Material 3 (`ThemeData.useMaterial3`) + `flex_color_scheme` — light/dark, dynamic color (Android 12+), responsive breakpoints.
- **Code Generation:** `build_runner` — `freezed` (immutable data), `json_serializable` (DTOs), `retrofit` (API client), `drift` (DB), `riverpod_generator` (providers).
- **Testing:** `flutter_test` + `mocktail` + `patrol` (integration) — unit (domain/data), widget (presentation), integration (E2E).
- **Build:** `flutter build` — `apk`/`aab` (Android), `ipa` (iOS), `web` (WASM + SKIA), `windows`/`macos`/`linux` (desktop). Flavors: dev/staging/prod.
- **CI/CD:** 
  - **Web (WASM):** GitHub Actions → SSH to VPS → `docker compose up -d --build --no-deps mobile-flutter-web`
  - **Android:** GitHub Actions (ubuntu-latest) / Codemagic → `flutter build appbundle` → upload to Play Console
  - **iOS:** GitHub Actions (macos-latest) / Codemagic → `flutter build ipa` → upload to TestFlight
  - **Desktop:** GitHub Actions → `flutter build windows/macos/linux` → GitHub Releases
  - **Web (WASM):** GitHub Actions → SSH to VPS → `docker compose up -d --build --no-deps mobile-flutter-web`
- **Prohibido:** Monorepos, Bloc/Cubit (prefer Riverpod), GetX, Provider (legacy), SQLite raw, SDKs propietarios backend, Expo, Capacitor, KMP.