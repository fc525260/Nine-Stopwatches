# Changelog

## 1.0.1 - 2026-06-29

- Fixed stopwatch accuracy by measuring real elapsed time with Dart `Stopwatch` instead of adding a fixed 10 ms per timer callback.
- Added a regression test for real elapsed-time tracking.

## 1.0.0 - 2026-06-29

- Rebuilt the original PyQt stopwatch prototypes as a Flutter Windows desktop app.
- Added a Rust native core for stopwatch arithmetic and time formatting.
- Added a Rust portable launcher that embeds the Flutter release bundle into one Windows exe.
- Added responsive startup layout so all nine stopwatches are visible in the desktop viewport.
- Added GitHub Actions release workflow for Windows portable exe artifacts.
