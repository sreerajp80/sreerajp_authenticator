import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'l10n_test_helpers.dart';

/// Sanskrit must be real Sanskrit, never Hindi (language pack §4.1). This is
/// the pack's grep gate as a test, over `app_sa.arb` and the `sa` values in
/// `assets/config/app_config.json`.
void main() {
  // Word edges: whitespace, quotes, brackets, punctuation, daṇḍa, tag edges
  // and Markdown marks, as in the pack's PCRE pattern.
  const before = r'''(?<=[\s"'(\[{<>।,*_`#|:;~-]|^)''';
  const after = r'''(?=[\s"')\]}<>।,.?!*_`#|:;~-]|$)''';
  final hindiMarker = RegExp(
    '$before(?:था|थे|थी|हो|है|हैं|हूं|और)$after'
    '|करें|करना|करके|रहा|रही|रहे|गया|गयी|चाहिए|नहीं|लेकिन|क्या'
    '|आपका|आपकी|आपके|हमारा|मेरा|कृपया|सेटिंग्स|ऐप'
    r'|़|[क़-य़]',
    unicode: true,
    multiLine: true,
  );

  test('the pattern still catches a Hindi copula and allows Sanskrit', () {
    expect(hindiMarker.hasMatch('"यह ठीक है"'), isTrue);
    expect(hindiMarker.hasMatch('सेटिंग्स'), isTrue);
    expect(hindiMarker.hasMatch('ज़'), isTrue);
    expect(hindiMarker.hasMatch('पुनःस्थाप्यताम्'), isFalse);
    expect(hindiMarker.hasMatch('यथा तथा कथा'), isFalse);
  });

  test('app_sa.arb has no Hindi markers', () {
    final problems = [
      for (final entry in arbStrings('sa').entries)
        if (hindiMarker.hasMatch(entry.value))
          '${entry.key}: "${hindiMarker.firstMatch(entry.value)!.group(0)}"',
    ];
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('Sanskrit values in app_config.json have no Hindi markers', () {
    final problems = <String>[];
    void scan(String path, Object? value) {
      if (value is Map) {
        final sa = value['sa'];
        if (sa is String && hindiMarker.hasMatch(sa)) problems.add(path);
        for (final e in value.entries) {
          if (e.value is Map) scan('$path.${e.key}', e.value);
        }
      }
    }

    scan('app_config', readAppConfig());
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('every Sanskrit asset file has no Hindi markers', () {
    final files = Directory('assets')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => RegExp(r'_sa\.\w+$').hasMatch(f.path));
    for (final file in files) {
      expect(
        hindiMarker.hasMatch(file.readAsStringSync()),
        isFalse,
        reason: file.path,
      );
    }
  });
}
