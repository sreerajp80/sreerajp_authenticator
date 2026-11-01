import 'dart:convert';

/// RFC 4226's test secret. No real account uses this data.
const List<int> rfcSecretBytes = [
  0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, //
  0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30,
];

List<int> _varint(int value) {
  final out = <int>[];
  var rest = value;
  while (true) {
    final low = rest & 0x7f;
    rest = rest >>> 7;
    if (rest == 0) {
      out.add(low);
      return out;
    }
    out.add(low | 0x80);
  }
}

List<int> varintField(int number, int value) => [
  ..._varint(number << 3),
  ..._varint(value),
];

List<int> bytesField(int number, List<int> value) => [
  ..._varint((number << 3) | 2),
  ..._varint(value.length),
  ...value,
];

List<int> fixed64Field(int number) => [
  ..._varint((number << 3) | 1),
  ...List<int>.filled(8, 9),
];

List<int> fixed32Field(int number) => [
  ..._varint((number << 3) | 5),
  ...List<int>.filled(4, 9),
];

/// One account in Google's format. Defaults to a valid TOTP account.
List<int> migrationAccount({
  List<int> secret = rfcSecretBytes,
  String name = 'user@example.com',
  String issuer = 'Example',
  int algorithm = 1,
  int digits = 1,
  int type = 2,
  int? counter,
}) => [
  ...bytesField(1, secret),
  ...bytesField(2, utf8.encode(name)),
  ...bytesField(3, utf8.encode(issuer)),
  ...varintField(4, algorithm),
  ...varintField(5, digits),
  ...varintField(6, type),
  if (counter != null) ...varintField(7, counter),
];

List<int> migrationPayload(
  List<List<int>> accounts, {
  int batchSize = 1,
  int batchIndex = 0,
  int batchId = 1,
}) => [
  for (final account in accounts) ...bytesField(1, account),
  ...varintField(2, 1),
  ...varintField(3, batchSize),
  ...varintField(4, batchIndex),
  ...varintField(5, batchId),
];

String migrationLink(List<int> payload) =>
    'otpauth-migration://offline?data='
    '${Uri.encodeQueryComponent(base64.encode(payload))}';
