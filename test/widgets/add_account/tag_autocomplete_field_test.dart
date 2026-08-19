// File Path: sreerajp_authenticator/test/widgets/add_account/tag_autocomplete_field_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_authenticator/widgets/add_account/browse_tags_bottom_sheet.dart';
import 'package:sreerajp_authenticator/widgets/add_account/tag_autocomplete_field.dart';

void main() {
  group('TagAutocompleteField Tests', () {
    testWidgets('renders properly with label and browse button', (
      tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagAutocompleteField(
              controller: controller,
              availableTags: const ['Work', 'Finance', 'Crypto', 'Personal'],
            ),
          ),
        ),
      );

      expect(find.text('Tags (Comma separated)'), findsOneWidget);
      expect(find.byIcon(Icons.sell_outlined), findsOneWidget);
      expect(find.byIcon(Icons.label_outlined), findsOneWidget);
    });

    testWidgets(
      'displays autocomplete matching on 1st character and selects tag',
      (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TagAutocompleteField(
                controller: controller,
                availableTags: const ['Work', 'Finance', 'Crypto', 'Personal'],
              ),
            ),
          ),
        );

        // Tap field to focus
        await tester.tap(find.byType(TextFormField));
        await tester.pump();

        // Enter single character 'w' (1st character)
        await tester.enterText(find.byType(TextFormField), 'w');
        await tester.pumpAndSettle();

        // Should show '#Work' in suggestions overlay
        expect(find.text('#Work'), findsOneWidget);
        expect(find.text('Tap to add'), findsOneWidget);

        // Tap suggestion
        await tester.tap(find.text('#Work'));
        await tester.pumpAndSettle();

        // Controller text should now be 'Work, '
        expect(controller.text, 'Work, ');

        // Type 'f' for the second tag
        await tester.enterText(find.byType(TextFormField), 'Work, f');
        await tester.pumpAndSettle();

        // Should show '#Finance'
        expect(find.text('#Finance'), findsOneWidget);

        // Tap '#Finance'
        await tester.tap(find.text('#Finance'));
        await tester.pumpAndSettle();

        expect(controller.text, 'Work, Finance, ');
      },
    );

    testWidgets('excludes already selected tags from suggestions', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'Work, w');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagAutocompleteField(
              controller: controller,
              availableTags: const ['Work', 'Web3'],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'Work, w');
      await tester.pumpAndSettle();

      // '#Work' was already added before comma, so only '#Web3' should be suggested
      expect(find.text('#Web3'), findsOneWidget);
      expect(find.text('#Work'), findsNothing);
    });

    testWidgets('opens BrowseTagsBottomSheet and allows multi-selection', (
      tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagAutocompleteField(
              controller: controller,
              availableTags: const ['Work', 'Crypto', 'Personal'],
            ),
          ),
        ),
      );

      // Tap the browse button
      await tester.tap(find.byIcon(Icons.sell_outlined));
      await tester.pumpAndSettle();

      // Check bottom sheet contents
      expect(find.text('Browse Existing Tags'), findsOneWidget);
      expect(find.text('#Work'), findsOneWidget);
      expect(find.text('#Crypto'), findsOneWidget);
      expect(find.text('#Personal'), findsOneWidget);

      // Select 'Crypto' and 'Personal'
      await tester.tap(find.text('#Crypto'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('#Personal'));
      await tester.pumpAndSettle();

      // Tap Apply
      await tester.tap(find.text('Apply (2 selected)'));
      await tester.pumpAndSettle();

      // Check controller text
      expect(controller.text, 'Crypto, Personal, ');
    });

    testWidgets('BrowseTagsBottomSheet handles empty tag list', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagAutocompleteField(
              controller: controller,
              availableTags: const [],
            ),
          ),
        ),
      );

      // Tap the browse button
      await tester.tap(find.byIcon(Icons.sell_outlined));
      await tester.pumpAndSettle();

      expect(find.text('No existing tags found'), findsOneWidget);
      expect(
        find.text(
          'Type new tags in the text field to assign them to this entry.',
        ),
        findsOneWidget,
      );

      // Tap Done
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(controller.text, '');
    });

    testWidgets('BrowseTagsBottomSheet search filters tags', (tester) async {
      List<String>? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BrowseTagsBottomSheet(
              availableTags: const ['Alpha', 'Beta', 'Gamma'],
              currentlySelectedTags: const ['Alpha'],
              onTagsSelected: (tags) => selected = tags,
            ),
          ),
        ),
      );

      expect(find.text('#Alpha'), findsOneWidget);
      expect(find.text('#Beta'), findsOneWidget);
      expect(find.text('#Gamma'), findsOneWidget);

      // Enter search filter 'bet'
      await tester.enterText(
        find.widgetWithText(TextField, 'Search existing tags...'),
        'bet',
      );
      await tester.pumpAndSettle();

      expect(find.text('#Beta'), findsOneWidget);
      expect(find.text('#Alpha'), findsNothing);
      expect(find.text('#Gamma'), findsNothing);

      // Tap Clear All
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      // Tap Apply
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(selected, isEmpty);
    });
  });
}
