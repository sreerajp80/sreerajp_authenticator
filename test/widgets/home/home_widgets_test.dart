import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/models/group.dart';
import 'package:sreerajp_authenticator/providers/group_provider.dart';
import 'package:sreerajp_authenticator/widgets/home/home_empty_state.dart';
import 'package:sreerajp_authenticator/widgets/home/home_fab_button.dart';
import 'package:sreerajp_authenticator/widgets/home/home_group_tabs.dart';
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

  group('HomeGroupTabs', () {
    testWidgets('renders groups and reports selection changes', (tester) async {
      final provider = TestGroupsProvider([
        makeGroup(id: 1, name: 'Work', sortOrder: 0),
        makeGroup(id: 2, name: 'Personal', sortOrder: 1),
      ]);
      addTearDown(provider.dispose);

      int? selectedGroupId = 1;

      await tester.pumpWidget(
        ChangeNotifierProvider<GroupsProvider>.value(
          value: provider,
          child: MaterialApp(
            home: Scaffold(
              body: HomeGroupTabs(
                selectedGroupId: selectedGroupId,
                onGroupSelected: (value) {
                  selectedGroupId = value;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);

      tester.widget<GestureDetector>(_tabFinder('Work')).onTap?.call();
      await tester.pump();
      expect(selectedGroupId, isNull);

      selectedGroupId = 1;
      tester.widget<GestureDetector>(_tabFinder('Personal')).onTap?.call();
      await tester.pump();
      expect(selectedGroupId, 2);
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

Finder _tabFinder(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byType(GestureDetector),
  );
}

Future<void> pumpHomeWidget(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
  await tester.pumpAndSettle();
}

Group makeGroup({required int id, required String name, int sortOrder = 0}) {
  return Group(
    id: id,
    name: name,
    sortOrder: sortOrder,
    createdAt: DateTime.now(),
  );
}

class TestGroupsProvider extends GroupsProvider {
  TestGroupsProvider(List<Group> groups) : _groups = groups;

  final List<Group> _groups;

  @override
  List<Group> get groups => _groups;

  @override
  Future<void> loadGroups() async {}
}
