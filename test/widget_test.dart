import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/app.dart';
import 'package:todo_app/data/models/task_model.dart';
import 'package:todo_app/data/repositories/task_repository.dart';
import 'package:todo_app/presentation/providers/task_providers.dart';

class FakeTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<void> init() async {}

  @override
  List<Task> getTasks() => _tasks;

  @override
  Future<void> saveTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    } else {
      _tasks.add(task);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }

  @override
  Future<void> clear() async {
    _tasks.clear();
  }
}

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

final Uint8List _transparentImage = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x42, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets('App builds and loads home screen', (WidgetTester tester) async {
    final fakeRepository = FakeTaskRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: const TodoApp(),
      ),
    );

    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(TodoApp), findsOneWidget);
  });

  testWidgets('Profile customization and email removal works', (WidgetTester tester) async {
    final fakeRepository = FakeTaskRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: const TodoApp(),
      ),
    );

    // Initial load
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 1. Verify initial home greeting name is 'Alex Johnson'
    expect(find.text('Hi, Alex Johnson'), findsOneWidget);

    // 2. Switch to Profile tab
    final profileTab = find.text('Profile');
    expect(profileTab, findsOneWidget);
    await tester.tap(profileTab);
    await tester.pumpAndSettle();

    // 3. Verify email 'alex.johnson@example.com' is removed and the name is 'Alex Johnson'
    expect(find.text('alex.johnson@example.com'), findsNothing);
    expect(find.text('Alex Johnson'), findsOneWidget);

    final editIcon = find.byIcon(Icons.edit_rounded);
    expect(editIcon, findsOneWidget);
    await tester.tap(editIcon);
    await tester.pumpAndSettle();

    // 5. Verify the dialog title 'Edit Profile' is displayed
    expect(find.text('Edit Profile'), findsOneWidget);

    // 6. Locate Name text field, clear it, and type 'Alex Miller'
    final nameField = find.widgetWithText(TextField, 'Name');
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'Alex Miller');
    await tester.pumpAndSettle();

    // 7. Tap 'Save'
    final saveButton = find.text('Save');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // 8. Verify the Profile screen name displays 'Alex Miller' and no longer 'Alex Johnson'
    expect(find.text('Alex Miller'), findsOneWidget);
    expect(find.text('Alex Johnson'), findsNothing);

    // 9. Switch back to the Home tab
    final homeTab = find.text('Home');
    expect(homeTab, findsOneWidget);
    await tester.tap(homeTab);
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 10. Verify greeting updated to 'Hi, Alex Miller'
    expect(find.text('Hi, Alex Miller'), findsOneWidget);
  });
}
