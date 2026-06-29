# Agent Notes

## Project

- Root: repository root.
- Product: Nine Stopwatches, a Windows desktop Flutter app with Rust native stopwatch core.
- Do not commit generated artifacts such as `build/`, Rust `target/`, root `*.exe`, or bundle zip files.
- Do not commit local-only reference or handoff files such as `old/`, `docs/HANDOFF_*.md`, or `docs/REPLICA_AUDIT_*.md`.

## Required Checks

Run these before claiming implementation work is complete:

```powershell
flutter analyze
flutter test
cargo test --manifest-path rust/stopwatch_core/Cargo.toml
flutter build windows --release
```

For single-file release packaging, also run:

```powershell
Compress-Archive -Path build/windows/x64/runner/Release/* -DestinationPath build/windows/x64/runner/nine_stopwatches_bundle.zip -Force
cargo build --release --manifest-path rust/portable_launcher/Cargo.toml
```

## Architecture

- `lib/main.dart` owns Flutter UI, stopwatch state, responsive layout, and Dart FFI lookup.
- `rust/stopwatch_core` exports `nine_stopwatches_add_ms` and `nine_stopwatches_format`; Windows CMake links this static library into `nine_stopwatches.exe` and exports the symbols.
- `rust/portable_launcher` embeds `build/windows/x64/runner/nine_stopwatches_bundle.zip`, extracts it under `%LOCALAPPDATA%\NineStopwatches\portable\<bundle-hash>`, then starts `nine_stopwatches.exe`.

## Release Notes

- GitHub Actions release workflow is `.github/workflows/release.yml`.
- It is configured for tag pushes matching `v*`; do not push or publish unless the user asks.
