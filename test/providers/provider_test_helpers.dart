import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sreerajp_authenticator/models/account.dart';
import 'package:sreerajp_authenticator/models/group.dart';
import 'package:sreerajp_authenticator/services/database_service.dart';
import 'package:sreerajp_authenticator/services/otp_service.dart';

final Map<String, String> fakeSecureStorage = {};

void configureProviderTestBindings() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

Future<void> setUpProviderTestEnvironment({
  Map<String, Object> sharedPreferences = const {},
}) async {
  fakeSecureStorage.clear();
  SharedPreferences.setMockInitialValues(sharedPreferences);

  await DatabaseService.resetForTesting();
  DatabaseService.testDbPath = inMemoryDatabasePath;
  OTPService.clearCache();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'read':
              final key = methodCall.arguments['key'] as String;
              return fakeSecureStorage[key];
            case 'write':
              final key = methodCall.arguments['key'] as String;
              final value = methodCall.arguments['value'] as String;
              fakeSecureStorage[key] = value;
              return null;
            case 'delete':
              final key = methodCall.arguments['key'] as String;
              fakeSecureStorage.remove(key);
              return null;
            case 'deleteAll':
              fakeSecureStorage.clear();
              return null;
            default:
              return null;
          }
        },
      );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'isDeviceSupported':
              return true;
            case 'deviceSupportsBiometrics':
              return true;
            case 'getAvailableBiometrics':
              return <String>['fingerprint'];
            case 'authenticate':
              return true;
            default:
              return null;
          }
        },
      );
}

Future<void> tearDownProviderTestEnvironment() async {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        null,
      );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'),
        null,
      );

  OTPService.clearCache();
  await DatabaseService.resetForTesting();
  DatabaseService.testDbPath = null;
  fakeSecureStorage.clear();
}

Future<void> waitForCondition(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 2),
  Duration pollInterval = const Duration(milliseconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(pollInterval);
  }

  if (condition()) {
    return;
  }

  throw TestFailure('Condition not met within $timeout');
}

Future<void> settleAsyncWork([
  Duration duration = const Duration(milliseconds: 75),
]) async {
  await Future<void>.delayed(duration);
}

Account makeAccount({
  int? id,
  String name = 'GitHub',
  String secret = 'JBSWY3DPEHPK3PXP',
  String type = 'totp',
  String? issuer,
  String? description,
  int? counter,
  int digits = 6,
  int period = 30,
  String algorithm = 'SHA1',
  int? groupId,
  int sortOrder = 0,
}) {
  return Account(
    id: id,
    name: name,
    secret: secret,
    issuer: issuer,
    description: description,
    type: type,
    counter: counter,
    digits: digits,
    period: period,
    algorithm: algorithm,
    groupId: groupId,
    sortOrder: sortOrder,
  );
}

Group makeGroup({
  int? id,
  String name = 'Work',
  String? description,
  String color = 'blue',
  String? icon,
  int sortOrder = 0,
}) {
  return Group(
    id: id,
    name: name,
    description: description,
    color: color,
    icon: icon,
    sortOrder: sortOrder,
    createdAt: DateTime.now(),
  );
}
