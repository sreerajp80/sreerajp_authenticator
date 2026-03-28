import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/models/group.dart';

void main() {
  group('Group model', () {
    late Group groupModel;

    setUp(() {
      groupModel = Group(
        id: 1,
        name: 'Work',
        description: 'Accounts for work',
        color: 'green',
        icon: 'briefcase',
        sortOrder: 2,
        createdAt: DateTime.fromMillisecondsSinceEpoch(1727265600000),
      );
    });

    test('toMap produces correct map', () {
      final map = groupModel.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Work');
      expect(map['description'], 'Accounts for work');
      expect(map['color'], 'green');
      expect(map['icon'], 'briefcase');
      expect(map['sortOrder'], 2);
      expect(map['createdAt'], 1727265600000);
    });

    test('fromMap round-trips correctly', () {
      final map = groupModel.toMap();
      final restored = Group.fromMap(map);

      expect(restored.id, groupModel.id);
      expect(restored.name, groupModel.name);
      expect(restored.description, groupModel.description);
      expect(restored.color, groupModel.color);
      expect(restored.icon, groupModel.icon);
      expect(restored.sortOrder, groupModel.sortOrder);
      expect(restored.createdAt, groupModel.createdAt);
    });

    test('fromMap applies defaults for optional values', () {
      final restored = Group.fromMap({
        'id': null,
        'name': 'Personal',
        'description': null,
        'icon': null,
        'createdAt': null,
      });

      expect(restored.id, isNull);
      expect(restored.name, 'Personal');
      expect(restored.description, isNull);
      expect(restored.color, 'blue');
      expect(restored.icon, isNull);
      expect(restored.sortOrder, 0);
      expect(restored.createdAt, isNull);
    });

    test('copyWith overrides specified fields only', () {
      final copy = groupModel.copyWith(
        name: 'Personal',
        color: 'red',
        sortOrder: 4,
      );

      expect(copy.id, groupModel.id);
      expect(copy.name, 'Personal');
      expect(copy.description, groupModel.description);
      expect(copy.color, 'red');
      expect(copy.icon, groupModel.icon);
      expect(copy.sortOrder, 4);
      expect(copy.createdAt, groupModel.createdAt);
    });

    test('copyWith with no arguments returns identical values', () {
      final copy = groupModel.copyWith();

      expect(copy.id, groupModel.id);
      expect(copy.name, groupModel.name);
      expect(copy.description, groupModel.description);
      expect(copy.color, groupModel.color);
      expect(copy.icon, groupModel.icon);
      expect(copy.sortOrder, groupModel.sortOrder);
      expect(copy.createdAt, groupModel.createdAt);
    });

    test('default values applied correctly', () {
      final minimal = Group(name: 'Default Test');

      expect(minimal.id, isNull);
      expect(minimal.name, 'Default Test');
      expect(minimal.description, isNull);
      expect(minimal.color, 'blue');
      expect(minimal.icon, isNull);
      expect(minimal.sortOrder, 0);
      expect(minimal.createdAt, isNull);
    });
  });
}
