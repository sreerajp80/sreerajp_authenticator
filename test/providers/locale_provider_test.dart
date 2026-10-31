import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_authenticator/providers/locale_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<LocaleProvider> create(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return LocaleProvider(await SharedPreferences.getInstance());
  }

  test('follows the system when nothing is saved', () async {
    final provider = await create({});
    expect(provider.isSystem, isTrue);
    expect(provider.locale, isNull);
    expect(provider.selection, LocaleProvider.systemValue);
  });

  test('reads a saved declared language before the first frame', () async {
    final provider = await create({LocaleProvider.prefKey: 'sa'});
    expect(provider.locale, const Locale('sa'));
    expect(provider.selection, 'sa');
  });

  test('ignores a saved value that is not a declared language', () async {
    final provider = await create({LocaleProvider.prefKey: 'hi'});
    expect(provider.isSystem, isTrue);
  });

  test('saves the choice and notifies listeners', () async {
    final provider = await create({});
    var notified = 0;
    provider.addListener(() => notified++);

    await provider.setLanguage('ml');
    expect(provider.locale, const Locale('ml'));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LocaleProvider.prefKey), 'ml');

    await provider.setLanguage(LocaleProvider.systemValue);
    expect(provider.isSystem, isTrue);
    expect(prefs.getString(LocaleProvider.prefKey), LocaleProvider.systemValue);
    expect(notified, 2);
  });

  test('rejects an undeclared language', () async {
    final provider = await create({});
    await provider.setLanguage('hi');
    expect(provider.isSystem, isTrue);
  });
}
