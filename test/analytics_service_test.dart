import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/data/services/analytics_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AnalyticsService increments created and completed tasks', () async {
    final service = AnalyticsService();
    await service.init();

    expect(service.getTodayCreated(), 0);
    expect(service.getTodayCompleted(), 0);

    await service.incrementTasksCreated();
    await service.incrementTasksCreated();
    await service.incrementTasksCompleted();

    expect(service.getTodayCreated(), 2);
    expect(service.getTodayCompleted(), 1);
  });

  test('AnalyticsService records daily statistics and prunes to 30 days',
      () async {
    final service = AnalyticsService();
    await service.init();

    await service.incrementTasksCreated();
    await service.incrementTasksCompleted();

    await service.recordDailyStats(
      date: '2026-06-08',
      focusTimeSeconds: 120,
      appUsageTimeSeconds: 300,
    );

    final history = service.getHistory();
    expect(history.length, 1);
    expect(history[0].date, '2026-06-08');
    expect(history[0].tasksCreated, 1);
    expect(history[0].tasksCompleted, 1);
    expect(history[0].focusTimeSeconds, 120);
    expect(history[0].appUsageTimeSeconds, 300);

    expect(service.getTodayCreated(), 0);
    expect(service.getTodayCompleted(), 0);

    for (int i = 1; i <= 35; i++) {
      final dateStr = '2026-06-${i.toString().padLeft(2, '0')}';
      await service.recordDailyStats(
        date: dateStr,
        focusTimeSeconds: 100,
        appUsageTimeSeconds: 200,
      );
    }

    final historyPruned = service.getHistory();
    expect(historyPruned.length, 30);
  });
}
