import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';
import 'package:sreerajp_authenticator/widgets/qr_camera_view.dart';

void main() {
  group('QrCodeFilter', () {
    test('rejects null and empty text', () {
      final filter = QrCodeFilter(ignoreDuplicates: false);
      expect(filter.accept(null), isFalse);
      expect(filter.accept(''), isFalse);
    });

    test('skips a repeated code when asked', () {
      final filter = QrCodeFilter(ignoreDuplicates: true);
      expect(filter.accept('a'), isTrue);
      expect(filter.accept('a'), isFalse);
      expect(filter.accept('b'), isTrue);
      expect(filter.accept('a'), isTrue);
    });

    test('passes every frame for optical sync', () {
      final filter = QrCodeFilter(ignoreDuplicates: false);
      expect(filter.accept('a'), isTrue);
      expect(filter.accept('a'), isTrue);
    });
  });

  group('QrCameraView errors', () {
    Future<void> pumpView(
      WidgetTester tester,
      Future<List<CameraDescription>> Function() loadCameras,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: LocaleConfig.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: QrCameraView(onCode: (_) {}, loadCameras: loadCameras),
        ),
      );
      // The decoder isolate needs real time to start or fail.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 1)),
      );
      await tester.pump();
    }

    testWidgets('shows a localized message when there is no camera', (
      tester,
    ) async {
      await pumpView(tester, () async => const []);
      expect(
        find.text(
          'The camera is not available. You can enter the details by hand.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows no raw exception text when the camera fails', (
      tester,
    ) async {
      await pumpView(tester, () async => throw StateError('secret detail'));
      expect(find.textContaining('secret detail'), findsNothing);
      expect(
        find.text(
          'The camera is not available. You can enter the details by hand.',
        ),
        findsOneWidget,
      );
    });
  });
}
