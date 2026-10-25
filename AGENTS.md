# Sunset

A visual Flutter app builder. Users design apps by placing widgets on a canvas, no code needed. A desktop app (Linux, Windows, macOS) with a Flutter Web landing page. Self-hosted.

## What this codebase needs

- Refactor rather than duplicating code. The GUI and the CLI (`bin/sunset.dart`, `lib/cli/`) must share one implementation in `lib/core/` and `lib/state/` so features never get written twice.
- Keep 100% test coverage. Run `flutter test --coverage` and check `coverage/lcov.info` after changing code.
- Golden tests for every page live in `test/golden_test.dart`. Regenerate with `flutter test --update-goldens` and commit the PNGs.
- Every user-facing string goes through the ARB files in `lib/l10n/`. No hardcoded strings. Supported locales: en_GB (base), zh_Hans, ru, ga.
- Commit style: Conventional Commits, enforced by cocogitto (`cog check`). `cog.toml` drives versioning, never bump versions by hand.
- Grade-A code. Small focused files, no god files, no dead code, no defensive checks for impossible states.
