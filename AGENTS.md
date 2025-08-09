# Repository Guidelines

## Project Structure & Module Organization
- `bridge/`: C++17 WebF bridge (JS runtime, DOM/CSS, codegen); tests in `bridge/test/`.
- `webf/`: Dart/Flutter engine (DOM/layout/painting); tests in `webf/test/` and `webf/integration_test/`.
- `integration_tests/`: E2E and snapshot tests.
- `cli/`: WebF CLI (TypeScript) for code generation; tests in `cli/test/`.
- `scripts/`: Build, typings, and utility scripts.
- `webf_apps/`: Example apps (Vue + Cupertino UI). Third‑party in `bridge/third_party/`.

## Build, Test, and Development Commands
- Build bridge (macOS): `npm run build:bridge:macos`
- Build all platforms: `npm run build:bridge:all`
- Clean: `npm run build:clean`
- Generate bindings/types: `node scripts/generate_binding_code.js`
- All tests: `npm test`
- Bridge unit tests: `node scripts/run_bridge_unit_test.js`
- Flutter tests: `cd webf && flutter test`
- Integration tests: `cd integration_tests && npm run integration`
- Lint/format (Dart): `npm run lint` / `npm run format`

## Coding Style & Naming Conventions
- C++ (bridge): C++17, 2‑space indent, 120 cols, Chromium style (`.clang-format`). Files: `.cc/.h`.
- Dart (webf): See `webf/analysis_options.yaml`. Files: `snake_case.dart`; Classes: PascalCase; members: camelCase.
- TypeScript (cli): Strict TS; tests in `*.test.ts`. Keep generators pure and deterministic.

## Testing Guidelines
- Bridge: Google Test via `run_bridge_unit_test.js`. Add tests under `bridge/test/`.
- Dart/Flutter: Widget/unit in `webf/test/`; integration in `webf/integration_test/`. Use `WebFWidgetTestUtils` and `pumpAndSettle()` where needed.
- CLI: Jest (`cli/test/`), target ≥70% coverage for core modules.
- Naming: Mirror source paths; prefer small, behavior‑focused tests.

## Commit & Pull Request Guidelines
- Commits: Conventional style `type(scope): subject` (e.g., `fix(bridge): remove register kw from codegen`).
- PRs: Clear description, linked issues, steps to test; screenshots for UI changes in `webf_apps/`.
- CI hygiene: Run `node scripts/generate_binding_code.js`, build bridge, and ensure all tests + `npm run lint` pass.

## Security & Configuration Tips
- Initialize submodules: `git submodule update --init --recursive`.
- Prereqs: Flutter SDK, CMake/Clang (macOS), Xcode/NDK as needed. Use `WEBF_BUILD=Release` or `ENABLE_PROFILE=true` when required.

