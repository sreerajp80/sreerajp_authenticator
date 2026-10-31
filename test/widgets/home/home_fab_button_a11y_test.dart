import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/widgets/home/home_fab_button.dart';

/// The add button works with a keyboard, a mouse and a screen reader, not only
/// by touch (engineering standard §7.5, §7.8).
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<List<String>> pumpButton(WidgetTester tester) async {
    final calls = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: LocaleConfig.localizationsDelegates,
        supportedLocales: LocaleConfig.supportedLocales,
        home: Scaffold(
          body: Center(
            child: HomeFabButton(
              onQrScan: () => calls.add('scan'),
              onManualEntry: () => calls.add('manual'),
              fabAnimation: const AlwaysStoppedAnimation(1),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    return calls;
  }

  testWidgets('a tap scans, and the button has a name', (tester) async {
    final handle = tester.ensureSemantics();
    final calls = await pumpButton(tester);

    expect(find.bySemanticsLabel(l10n.tooltipAddAccount), findsOneWidget);
    await tester.tap(find.byType(HomeFabButton));
    await tester.pump(const Duration(seconds: 1));
    expect(calls, ['scan']);
    handle.dispose();
  });

  testWidgets('Tab then Enter scans', (tester) async {
    final calls = await pumpButton(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump(const Duration(seconds: 1));
    expect(calls, ['scan']);
  });

  testWidgets('Shift+F10 reaches manual entry', (tester) async {
    final calls = await pumpButton(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.f10);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.labelManualEntry));
    await tester.pumpAndSettle();
    expect(calls, ['manual']);
  });

  testWidgets('right-click reaches manual entry', (tester) async {
    final calls = await pumpButton(tester);

    await tester.tap(find.byType(HomeFabButton), buttons: kSecondaryButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.labelManualEntry));
    await tester.pumpAndSettle();
    expect(calls, ['manual']);
  });
}
