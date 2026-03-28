// File Path: sreerajp_authenticator/lib/models/account.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 September 25
// Description: Model class for Account

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
  int? groupId;
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
    this.groupId,
    DateTime? createdAt,
    this.sortOrder = 0,
  }) : createdAt = createdAt ?? DateTime.now();

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
      'groupId': groupId,
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
      groupId: map['groupId'],
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
    int? groupId,
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
      groupId: groupId ?? this.groupId,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
