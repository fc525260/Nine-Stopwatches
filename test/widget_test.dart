import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nine_stopwatches/main.dart';

void main() {
  testWidgets('renders nine stopwatch cards and global controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NineStopwatchesApp());

    for (var index = 1; index <= 9; index++) {
      expect(find.text('秒表 $index'), findsOneWidget);
    }
    expect(find.text('全部暂停'), findsOneWidget);
    expect(find.text('全部重置'), findsOneWidget);
    expect(find.text('00:00:00'), findsNWidgets(9));
    expect(find.text('000'), findsNWidgets(9));
  });

  testWidgets('single stopwatch and global actions update state text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NineStopwatchesApp());

    await tester.tap(find.widgetWithText(ElevatedButton, '开始').first);
    await tester.pump();
    expect(find.text('运行中 1 / 9'), findsOneWidget);
    expect(find.text('秒表 1 已开始'), findsOneWidget);

    await tester.tap(find.text('全部暂停'));
    await tester.pump();
    expect(find.text('运行中 0 / 9'), findsOneWidget);
    expect(find.text('所有秒表已暂停'), findsOneWidget);

    await tester.tap(find.text('全部重置'));
    await tester.pump();
    expect(find.text('所有秒表已重置'), findsOneWidget);
  });

  test('stopwatch model follows real elapsed time', () async {
    final stopwatch = StopwatchModel(label: '测试秒表');

    stopwatch.start();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    stopwatch.syncElapsed();
    stopwatch.pause();

    expect(stopwatch.elapsedMs, greaterThanOrEqualTo(80));
    expect(stopwatch.elapsedMs, lessThan(500));
  });

  testWidgets('fits all nine stopwatch cards in the first desktop viewport', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const NineStopwatchesApp());

    expect(find.text('秒表 9'), findsOneWidget);
    expect(tester.getBottomLeft(find.text('秒表 9')).dy, lessThan(700));
    expect(tester.takeException(), isNull);
  });
}
