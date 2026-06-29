import 'dart:async';
import 'dart:ffi' hide Size;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const NineStopwatchesApp());
}

class NineStopwatchesApp extends StatelessWidget {
  const NineStopwatchesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '九个秒表',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: AppColors.inkBlack,
          secondary: AppColors.cooperativeGreen,
          surface: AppColors.paperWhite,
          onSurface: AppColors.inkBlack,
        ),
        scaffoldBackgroundColor: AppColors.paperWhite,
        fontFamily: 'Microsoft YaHei',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.inkBlack, letterSpacing: 0.16),
        ),
      ),
      home: const StopwatchHomePage(),
    );
  }
}

class StopwatchHomePage extends StatefulWidget {
  const StopwatchHomePage({super.key});

  @override
  State<StopwatchHomePage> createState() => _StopwatchHomePageState();
}

class _StopwatchHomePageState extends State<StopwatchHomePage> {
  static const _stopwatchCount = 9;
  static const _tick = Duration(milliseconds: 10);

  late final List<StopwatchModel> _stopwatches;
  Timer? _timer;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _stopwatches = List.generate(
      _stopwatchCount,
      (index) => StopwatchModel(label: '秒表 ${index + 1}'),
    );
    _timer = Timer.periodic(_tick, _advanceRunningStopwatches);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _advanceRunningStopwatches(Timer timer) {
    var didChange = false;
    for (final stopwatch in _stopwatches) {
      if (stopwatch.isRunning) {
        stopwatch.elapsedMs = StopwatchCore.add(stopwatch.elapsedMs, 10);
        didChange = true;
      }
    }
    if (didChange && mounted) {
      setState(() {});
    }
  }

  void _start(StopwatchModel stopwatch) {
    setState(() {
      stopwatch.isRunning = true;
      _statusMessage = '${stopwatch.label} 已开始';
    });
  }

  void _pause(StopwatchModel stopwatch) {
    setState(() {
      stopwatch.isRunning = false;
      _statusMessage = '${stopwatch.label} 已暂停';
    });
  }

  void _reset(StopwatchModel stopwatch) {
    setState(() {
      stopwatch
        ..elapsedMs = 0
        ..isRunning = false;
      _statusMessage = '${stopwatch.label} 已重置';
    });
  }

  void _pauseAll() {
    setState(() {
      for (final stopwatch in _stopwatches) {
        stopwatch.isRunning = false;
      }
      _statusMessage = '所有秒表已暂停';
    });
  }

  void _resetAll() {
    setState(() {
      for (final stopwatch in _stopwatches) {
        stopwatch
          ..elapsedMs = 0
          ..isRunning = false;
      }
      _statusMessage = '所有秒表已重置';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 820;
            return Column(
              children: [
                AppHeader(
                  statusMessage: _statusMessage,
                  runningCount: _stopwatches
                      .where((stopwatch) => stopwatch.isRunning)
                      .length,
                  onPauseAll: _pauseAll,
                  onResetAll: _resetAll,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, bodyConstraints) {
                      final gridMetrics = GridMetrics.fromConstraints(
                        bodyConstraints,
                        isCompact: isCompact,
                      );
                      return SingleChildScrollView(
                        physics: gridMetrics.fitsViewport
                            ? const NeverScrollableScrollPhysics()
                            : const ClampingScrollPhysics(),
                        padding: gridMetrics.padding,
                        child: StopwatchGrid(
                          stopwatches: _stopwatches,
                          metrics: gridMetrics,
                          onStart: _start,
                          onPause: _pause,
                          onReset: _reset,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.statusMessage,
    required this.runningCount,
    required this.onPauseAll,
    required this.onResetAll,
    super.key,
  });

  final String? statusMessage;
  final int runningCount;
  final VoidCallback onPauseAll;
  final VoidCallback onResetAll;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.paperWhite,
        border: Border(bottom: BorderSide(color: AppColors.inkBlack, width: 1)),
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 20)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandMark(),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '九个秒表',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.96,
                      ),
                    ),
                    Text(
                      '运行中 $runningCount / 9',
                      style: const TextStyle(
                        color: AppColors.steelGray,
                        fontSize: 12,
                        letterSpacing: 0.13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (statusMessage != null)
              StatusPill(message: statusMessage!)
            else
              const StatusPill(message: '每个计时器独立控制'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PillButton(
                  label: '全部暂停',
                  icon: Icons.pause_rounded,
                  onPressed: onPauseAll,
                ),
                const SizedBox(width: 10),
                PillButton(
                  label: '全部重置',
                  icon: Icons.restart_alt_rounded,
                  onPressed: onResetAll,
                  outlined: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.cooperativeGreen,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          '9',
          style: TextStyle(
            color: AppColors.inkBlack,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.mintWhisper,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.inkBlack),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 14, letterSpacing: 0.14),
      ),
    );
  }
}

class GridMetrics {
  const GridMetrics({
    required this.crossAxisCount,
    required this.spacing,
    required this.cardHeight,
    required this.padding,
    required this.cardDensity,
    required this.fitsViewport,
  });

  final int crossAxisCount;
  final double spacing;
  final double cardHeight;
  final EdgeInsets padding;
  final CardDensity cardDensity;
  final bool fitsViewport;

  factory GridMetrics.fromConstraints(
    BoxConstraints constraints, {
    required bool isCompact,
  }) {
    if (isCompact) {
      return const GridMetrics(
        crossAxisCount: 1,
        spacing: 14,
        cardHeight: 196,
        padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
        cardDensity: CardDensity.comfortable,
        fitsViewport: false,
      );
    }

    const rowCount = 3;
    const verticalPadding = 24.0;
    const minimumCardHeight = 166.0;
    final viewportHeight = constraints.maxHeight.isFinite
        ? constraints.maxHeight
        : 720.0;
    final spacing = viewportHeight < 690 ? 12.0 : 16.0;
    final availableHeight = viewportHeight - verticalPadding * 2 - spacing * 2;
    final cardHeight = (availableHeight / rowCount).clamp(
      minimumCardHeight,
      220.0,
    );
    final requiredHeight = cardHeight * rowCount + spacing * 2 + 48;

    return GridMetrics(
      crossAxisCount: 3,
      spacing: spacing,
      cardHeight: cardHeight,
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      cardDensity: cardHeight < 184
          ? CardDensity.tight
          : cardHeight < 204
          ? CardDensity.medium
          : CardDensity.comfortable,
      fitsViewport: requiredHeight <= viewportHeight,
    );
  }
}

class CardDensity {
  const CardDensity({
    required this.padding,
    required this.labelFontSize,
    required this.timeFontSize,
    required this.msFontSize,
    required this.buttonGap,
    required this.isTight,
  });

  final double padding;
  final double labelFontSize;
  final double timeFontSize;
  final double msFontSize;
  final double buttonGap;
  final bool isTight;

  static const comfortable = CardDensity(
    padding: 18,
    labelFontSize: 16,
    timeFontSize: 44,
    msFontSize: 14,
    buttonGap: 18,
    isTight: false,
  );

  static const medium = CardDensity(
    padding: 16,
    labelFontSize: 15,
    timeFontSize: 38,
    msFontSize: 13,
    buttonGap: 14,
    isTight: true,
  );

  static const tight = CardDensity(
    padding: 14,
    labelFontSize: 14,
    timeFontSize: 32,
    msFontSize: 12,
    buttonGap: 10,
    isTight: true,
  );
}

class StopwatchGrid extends StatelessWidget {
  const StopwatchGrid({
    required this.stopwatches,
    required this.metrics,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    super.key,
  });

  final List<StopwatchModel> stopwatches;
  final GridMetrics metrics;
  final ValueChanged<StopwatchModel> onStart;
  final ValueChanged<StopwatchModel> onPause;
  final ValueChanged<StopwatchModel> onReset;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: stopwatches.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: metrics.crossAxisCount,
        crossAxisSpacing: metrics.spacing,
        mainAxisSpacing: metrics.spacing,
        mainAxisExtent: metrics.cardHeight,
      ),
      itemBuilder: (context, index) {
        final stopwatch = stopwatches[index];
        return StopwatchCard(
          stopwatch: stopwatch,
          index: index,
          density: metrics.cardDensity,
          onStart: () => onStart(stopwatch),
          onPause: () => onPause(stopwatch),
          onReset: () => onReset(stopwatch),
        );
      },
    );
  }
}

class StopwatchCard extends StatelessWidget {
  const StopwatchCard({
    required this.stopwatch,
    required this.index,
    required this.density,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    super.key,
  });

  final StopwatchModel stopwatch;
  final int index;
  final CardDensity density;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;

  static const _surfaces = [
    AppColors.cooperativeGreen,
    AppColors.mintWhisper,
    AppColors.civicBlue,
    AppColors.paperWhite,
    AppColors.sunsetCoral,
  ];

  @override
  Widget build(BuildContext context) {
    final surface = _surfaces[index % _surfaces.length];
    final time = StopwatchCore.format(stopwatch.elapsedMs);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inkBlack, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(density.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stopwatch.label,
                  style: TextStyle(
                    fontSize: density.labelFontSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                RunningBadge(isRunning: stopwatch.isRunning),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      time.main,
                      maxLines: 1,
                      style: TextStyle(
                        color: AppColors.inkBlack,
                        fontSize: density.timeFontSize,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    time.milliseconds,
                    style: TextStyle(
                      color: AppColors.steelGray,
                      fontSize: density.msFontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: density.buttonGap),
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    label: '开始',
                    icon: Icons.play_arrow_rounded,
                    onPressed: onStart,
                    dense: density.isTight,
                  ),
                ),
                const SizedBox(width: 8),
                IconPillButton(
                  tooltip: '暂停',
                  icon: Icons.pause_rounded,
                  onPressed: onPause,
                ),
                const SizedBox(width: 8),
                IconPillButton(
                  tooltip: '重置',
                  icon: Icons.restart_alt_rounded,
                  onPressed: onReset,
                  outlined: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RunningBadge extends StatelessWidget {
  const RunningBadge({required this.isRunning, super.key});

  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isRunning ? AppColors.inkBlack : AppColors.paperWhite,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.inkBlack),
      ),
      child: Text(
        isRunning ? '运行' : '暂停',
        style: TextStyle(
          color: isRunning ? AppColors.paperWhite : AppColors.inkBlack,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.48,
        ),
      ),
    );
  }
}

class PillButton extends StatelessWidget {
  const PillButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.outlined = false,
    this.dense = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool outlined;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final foreground = outlined ? AppColors.inkBlack : AppColors.paperWhite;
    final background = outlined ? AppColors.paperWhite : AppColors.inkBlack;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: dense ? 17 : 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        foregroundColor: foreground,
        backgroundColor: background,
        minimumSize: Size(0, dense ? 40 : 44),
        padding: EdgeInsets.symmetric(
          horizontal: dense ? 14 : 20,
          vertical: dense ? 8 : 10,
        ),
        textStyle: TextStyle(
          fontSize: dense ? 13 : 14,
          fontWeight: FontWeight.w700,
          letterSpacing: dense ? 0.13 : 0.14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: const BorderSide(color: AppColors.inkBlack),
        ),
      ),
    );
  }
}

class IconPillButton extends StatelessWidget {
  const IconPillButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.outlined = false,
    super.key,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: 40,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          color: outlined ? AppColors.inkBlack : AppColors.paperWhite,
          style: IconButton.styleFrom(
            backgroundColor: outlined
                ? AppColors.paperWhite
                : AppColors.inkBlack,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
              side: const BorderSide(color: AppColors.inkBlack),
            ),
          ),
        ),
      ),
    );
  }
}

class StopwatchModel {
  StopwatchModel({required this.label});

  final String label;
  int elapsedMs = 0;
  bool isRunning = false;
}

class FormattedTime {
  const FormattedTime({required this.main, required this.milliseconds});

  final String main;
  final String milliseconds;
}

class StopwatchCore {
  static final DynamicLibrary _library = Platform.isWindows
      ? DynamicLibrary.executable()
      : DynamicLibrary.process();

  static final int Function(int elapsedMs, int deltaMs)? _add = _lookupAdd();

  static final void Function(int elapsedMs, Pointer<Utf8> buffer, int len)?
  _format = _lookupFormat();

  static int Function(int elapsedMs, int deltaMs)? _lookupAdd() {
    try {
      return _library
          .lookupFunction<Int64 Function(Int64, Int64), int Function(int, int)>(
            'nine_stopwatches_add_ms',
          );
    } on ArgumentError {
      return null;
    }
  }

  static void Function(int elapsedMs, Pointer<Utf8> buffer, int len)?
  _lookupFormat() {
    try {
      return _library.lookupFunction<
        Void Function(Int64, Pointer<Utf8>, UintPtr),
        void Function(int, Pointer<Utf8>, int)
      >('nine_stopwatches_format');
    } on ArgumentError {
      return null;
    }
  }

  static int add(int elapsedMs, int deltaMs) =>
      _add?.call(elapsedMs, deltaMs) ?? (elapsedMs + deltaMs).clamp(0, 1 << 62);

  static FormattedTime format(int elapsedMs) {
    final formatWithRust = _format;
    if (formatWithRust == null) {
      return _formatInDart(elapsedMs);
    }

    final buffer = calloc<Uint8>(16);
    try {
      formatWithRust(elapsedMs, buffer.cast<Utf8>(), 16);
      final value = buffer.cast<Utf8>().toDartString();
      final parts = value.split('.');
      return FormattedTime(
        main: parts.first,
        milliseconds: parts.length > 1 ? parts[1] : '000',
      );
    } finally {
      calloc.free(buffer);
    }
  }

  static FormattedTime _formatInDart(int elapsedMs) {
    final safeElapsed = elapsedMs < 0 ? 0 : elapsedMs;
    final totalSeconds = safeElapsed ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final milliseconds = safeElapsed % 1000;
    return FormattedTime(
      main:
          '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}',
      milliseconds: milliseconds.toString().padLeft(3, '0'),
    );
  }
}

abstract final class AppColors {
  static const cooperativeGreen = Color(0xFF44D991);
  static const civicBlue = Color(0xFF4C92E9);
  static const sunsetCoral = Color(0xFFFF6A51);
  static const mintWhisper = Color(0xFFEAF9F2);
  static const inkBlack = Color(0xFF000000);
  static const paperWhite = Color(0xFFFFFFFF);
  static const steelGray = Color(0xFF666666);
}
