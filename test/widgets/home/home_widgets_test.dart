import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/widgets/home/home_empty_state.dart';
import 'package:sreerajp_authenticator/widgets/home/home_fab_button.dart';
import 'package:sreerajp_authenticator/widgets/home/home_search_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall methodCall,
        ) async {
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('HomeEmptyState', () {
    testWidgets('shows onboarding copy when there is no search query', (
      tester,
    ) async {
      await pumpHomeWidget(tester, const HomeEmptyState(searchQuery: ''));

      expect(find.text('No accounts yet'), findsOneWidget);
      expect(
        find.text('Tap the + button to add your first account'),
        findsOneWidget,
      );
      expect(
        find.text('Tip: Long press + button for more options'),
        findsOneWidget,
      );
    });

    testWidgets('shows search-specific copy when a query is active', (
      tester,
    ) async {
      await pumpHomeWidget(tester, const HomeEmptyState(searchQuery: 'github'));

      expect(find.text('No accounts found'), findsOneWidget);
      expect(find.text('Try a different search term'), findsOneWidget);
    });
  });

  group('HomeSearchBar', () {
    testWidgets('forwards search text changes', (tester) async {
      var latestQuery = '';

      await pumpHomeWidget(
        tester,
        HomeSearchBar(
          searchQuery: '',
          onChanged: (value) {
            latestQuery = value;
          },
          onClear: () {},
        ),
      );

      await tester.enterText(find.byType(TextField), 'GitHub');

      expect(latestQuery, 'GitHub');
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('shows a clear action for active searches', (tester) async {
      var clearTapped = 0;

      await pumpHomeWidget(
        tester,
        HomeSearchBar(
          searchQuery: 'GitHub',
          onChanged: (_) {},
          onClear: () {
            clearTapped += 1;
          },
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(clearTapped, 1);
    });
  });

  group('HomeFabButton', () {
    testWidgets('tap triggers QR scan', (tester) async {
      var qrScanTapped = 0;
      var manualEntryTapped = 0;

      await pumpHomeWidget(
        tester,
        HomeFabButton(
          onQrScan: () {
            qrScanTapped += 1;
          },
          onManualEntry: () {
            manualEntryTapped += 1;
          },
          fabAnimation: kAlwaysCompleteAnimation,
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(qrScanTapped, 1);
      expect(manualEntryTapped, 0);
    });

    testWidgets('long press opens menu and triggers manual entry', (
      tester,
    ) async {
      var qrScanTapped = 0;
      var manualEntryTapped = 0;

      await pumpHomeWidget(
        tester,
        HomeFabButton(
          onQrScan: () {
            qrScanTapped += 1;
          },
          onManualEntry: () {
            manualEntryTapped += 1;
          },
          fabAnimation: kAlwaysCompleteAnimation,
        ),
      );

      await tester.longPress(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('QR Scanner'), findsOneWidget);
      expect(find.text('Manual Entry'), findsOneWidget);

      await tester.tap(find.text('Manual Entry'));
      await tester.pumpAndSettle();

      expect(qrScanTapped, 0);
      expect(manualEntryTapped, 1);
    });
  });
}

Future<void> pumpHomeWidget(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
  await tester.pumpAndSettle();
}
