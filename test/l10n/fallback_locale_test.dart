import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

/// Flutter has no framework translation for Sanskrit; the fallback delegates
/// must keep Material widgets working under `sa` (engineering standard §8.3.1,
/// language pack §1.1).
void main() {
  Widget app(Locale locale, Widget home) => MaterialApp(
    locale: locale,
    supportedLocales: LocaleConfig.supportedLocales,
    localizationsDelegates: LocaleConfig.localizationsDelegates,
    home: home,
  );

  for (final locale in LocaleConfig.supportedLocales) {
    testWidgets('framework and app strings load for ${locale.languageCode}', (
      tester,
    ) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        app(
          locale,
          Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(MaterialLocalizations.of(ctx), isNotNull);
      expect(CupertinoLocalizations.of(ctx), isNotNull);
      expect(
        AppLocalizations.of(ctx).localeName,
        startsWith(locale.languageCode),
      );
    });
  }

  testWidgets('Malayalam gets real Malayalam framework strings', (
    tester,
  ) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      app(
        const Locale('ml'),
        Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(MaterialLocalizations.of(ctx).cancelButtonLabel, isNot('Cancel'));
  });

  testWidgets('date picker and dialog open under Sanskrit', (tester) async {
    await tester.pumpWidget(
      app(
        const Locale('sa'),
        Builder(
          builder: (context) => Column(
            children: [
              TextButton(
                onPressed: () => showDatePicker(
                  context: context,
                  initialDate: DateTime(2026, 10, 29),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                ),
                child: const Text('date'),
              ),
              TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const AlertDialog(content: Text('dialog')),
                ),
                child: const Text('dialog'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('date'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('dialog').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  test('formattingLocale never hands Sanskrit to intl', () {
    expect(LocaleConfig.formattingLocale(const Locale('sa')), 'en');
  });

  test('unknown device languages resolve to English', () {
    expect(LocaleConfig.resolve(const Locale('hi')), const Locale('en'));
    expect(LocaleConfig.resolve(const Locale('ml', 'IN')), const Locale('ml'));
    expect(LocaleConfig.resolve(null), const Locale('en'));
  });
}
