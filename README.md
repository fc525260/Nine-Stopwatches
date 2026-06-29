# 九个秒表

一个 Windows 桌面秒表工具。应用启动后直接显示 3 x 3 的九个独立秒表，每个秒表都可以单独开始、暂停、重置，也支持一键全部暂停和一键全部重置。

![九个秒表 GUI 截图](docs/images/gui-main.png)

## 功能

- 9 个独立秒表。
- 单个秒表开始、暂停、重置。
- 一键全部暂停、全部重置。
- 启动后优先在首屏显示全部 9 个秒表。
- 基于真实经过时间计时，避免定时器刷新误差影响秒表速度。
- 支持构建为单文件 Windows EXE。

## 环境要求

- Flutter stable，并启用 Windows desktop 支持。
- Rust stable toolchain。
- Visual Studio Build Tools，包含 MSVC 和 Windows SDK。

建议将 `flutter` 和 `cargo` 加入 PATH。也可以通过 `FLUTTER_BIN` 环境变量指定 Flutter 可执行文件路径。

## 本地运行与验证

```powershell
flutter pub get
flutter analyze
flutter test
cargo test --manifest-path rust/stopwatch_core/Cargo.toml
flutter build windows --release
```

## 本地构建单文件 EXE

```powershell
.\scripts\build_portable.ps1
```

脚本会构建 Flutter Windows release，生成嵌入式 bundle，编译 Rust 启动器，并在项目根目录输出：

```text
九个秒表.exe
```

## 项目结构

```text
lib/                         Flutter GUI、状态管理和 Dart FFI 桥接
rust/stopwatch_core/         Rust 秒表核心，静态链接到 Windows runner
rust/portable_launcher/      Rust 单文件启动器，嵌入 Flutter release bundle
windows/                     Flutter Windows runner 与 CMake 集成
test/                        Flutter widget 测试
docs/                        README 截图等公开文档资源
scripts/                     本地构建脚本
```

## 技术说明

- Flutter 负责窗口、布局、交互和响应式 3 x 3 秒表界面。
- Rust `stopwatch_core` 负责时间加法和 `HH:MM:SS.mmm` 格式化，并通过 FFI 暴露给 Dart。
- Rust `portable_launcher` 将 Flutter release bundle 嵌入单个 EXE，启动时解包并运行桌面应用。

## 许可证

本项目使用 MIT License，详见 [LICENSE](LICENSE)。
