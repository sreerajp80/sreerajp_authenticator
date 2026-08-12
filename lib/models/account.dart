// File Path: sreerajp_authenticator/lib/models/account.dart
// Author: Sreeraj P
// Description: Model class for Account with tags support

class Account {
  int? id;
  String name;
  String secret;
  String? issuer;
  String? description;
  String type; // 'totp' or 'hotp'
  int? counter; // For HOTP
  int digits;
  int period; // For TOTP (usually 30 seconds)
  String algorithm; // SHA1, SHA256, SHA512
  List<String> tags;
  DateTime createdAt;
  int sortOrder;

  Account({
    this.id,
    required this.name,
    required this.secret,
    this.issuer,
    this.description,
    required this.type,
    this.counter,
    this.digits = 6,
    this.period = 30,
    this.algorithm = 'SHA1',
    List<String>? tags,
    DateTime? createdAt,
    this.sortOrder = 0,
  }) : tags = tags ?? const [],
       createdAt = createdAt ?? DateTime.now();

  static List<String> _parseTags(dynamic rawTags) {
    if (rawTags == null) return [];
    if (rawTags is List) {
      return rawTags
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (rawTags is String) {
      if (rawTags.trim().isEmpty) return [];
      return rawTags
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'secret': secret,
      'issuer': issuer,
      'description': description,
      'type': type,
      'counter': counter,
      'digits': digits,
      'period': period,
      'algorithm': algorithm,
      'tags': tags.join(','),
      'createdAt': createdAt.toIso8601String(),
      'sortOrder': sortOrder,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      secret: map['secret'],
      issuer: map['issuer'],
      description: map['description'],
      type: map['type'],
      counter: map['counter'],
      digits: map['digits'],
      period: map['period'],
      algorithm: map['algorithm'],
      tags: _parseTags(map['tags']),
      createdAt: DateTime.parse(map['createdAt']),
      sortOrder: map['sortOrder'],
    );
  }

  Account copyWith({
    int? id,
    String? name,
    String? secret,
    String? issuer,
    String? description,
    String? type,
    int? counter,
    int? digits,
    int? period,
    String? algorithm,
    List<String>? tags,
    DateTime? createdAt,
    int? sortOrder,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      secret: secret ?? this.secret,
      issuer: issuer ?? this.issuer,
      description: description ?? this.description,
      type: type ?? this.type,
      counter: counter ?? this.counter,
      digits: digits ?? this.digits,
      period: period ?? this.period,
      algorithm: algorithm ?? this.algorithm,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
