import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sreerajp_authenticator/config/locale_config.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations_ml.dart';
import 'package:sreerajp_authenticator/providers/account_provider.dart';
import 'package:sreerajp_authenticator/widgets/home/home_tag_cloud_view.dart';

import '../../providers/provider_test_helpers.dart';

void main() {
  configureProviderTestBindings();

  setUp(() async {
    await setUpProviderTestEnvironment(sharedPreferences: const {});
  });

  tearDown(() async {
    await tearDownProviderTestEnvironment();
  });

  testWidgets('Manage tags button stays on a narrow screen in Malayalam', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late final AccountsProvider provider;
    await tester.runAsync(() async {
      provider = AccountsProvider();
      await waitForCondition(
        () => !provider.isLoading && !provider.isPreDecrypting,
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ml'),
        localizationsDelegates: LocaleConfig.localizationsDelegates,
        supportedLocales: LocaleConfig.supportedLocales,
        home: Scaffold(
          body: ChangeNotifierProvider<AccountsProvider>.value(
            value: provider,
            child: HomeTagCloudView(onTagSelected: () {}),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);

    final button = find.byTooltip(AppLocalizationsMl().actionManageTags);
    expect(button, findsOneWidget);
    expect(tester.getRect(button).right, lessThanOrEqualTo(360));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
