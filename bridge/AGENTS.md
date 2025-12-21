# Repository Guidelines

## Project Structure & Module Organization
- `bridge/`: C++17 native bridge (JS runtime, DOM/CSS, bindings). Core code in `bridge/core/`; generated code in `bridge/code_gen/`; unit tests in `bridge/test/`; third-party deps in `bridge/third_party/`.
- `webf/`: Dart/Flutter engine (DOM/layout/painting). Tests in `webf/test/` and `webf/integration_test/`.
- `cli/`: TypeScript CLI/codegen helpers. Tests in `cli/test/`.
- `integration_tests/`: E2E + snapshot runner and tooling.
- `scripts/`: Repo-wide build/codegen utilities invoked by `npm run ...`.

## Build, Test, and Development Commands
Run from repo root (`../`) unless noted:
- Install dependencies: `npm install`
- Build bridge (macOS): `npm run build:bridge:macos` (other targets: `build:bridge:{android,ios,linux,windows}`)
- Clean build artifacts: `npm run build:clean`
- Regenerate bindings/types: `npm run bindgen` (don’t hand-edit files under `bridge/code_gen/`)
- Bridge unit tests: `node scripts/run_bridge_unit_test.js`
- Flutter analyze/format: `npm run lint` / `npm run format`
- Flutter tests: `cd webf && flutter test`
- Integration tests: `cd integration_tests && npm run integration`
- CLI tests: `cd cli && npm test`

## Coding Style & Naming Conventions
- C++ (bridge): 2-space indent, 120 cols, Chromium style via `.clang-format`; files use `.cc`/`.h`.
- Dart (webf): follow `webf/analysis_options.yaml`; files `snake_case.dart`, types `PascalCase`, members `camelCase`.
- TypeScript (cli): strict TS; keep generators deterministic; Jest tests use `*.test.ts`.

## Testing Guidelines
- Bridge uses GoogleTest; keep tests small and behavior-focused, and mirror source paths under `bridge/test/`.
- Do not create or run tests unless explicitly requested.
- Do not modify existing tests unless explicitly instructed.

## Commit & Pull Request Guidelines
- Use Conventional Commits: `type(scope): subject` (e.g., `fix(bridge): handle null QualifiedName`).
- PRs should include rationale, linked issues, and exact verification steps; add screenshots for UI changes in `webf_apps/`.
- Do not commit anything unless explicitly requested.

## Agent-Specific Instructions
- Always explain why changes are needed before making them.
- Do not build anything unless explicitly requested.

## Security & Configuration Tips
- Initialize submodules: `git submodule update --init --recursive`.
- Common build env: `WEBF_BUILD=Release`, `ENABLE_PROFILE=true`. Platform deps include Flutter SDK + CMake/Clang (macOS) and Xcode/NDK where applicable.
