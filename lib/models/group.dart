// File Path: sreerajp_authenticator/lib/models/group.dart
// Author: Sreeraj P
// Created: 2025 September 25
// Last Modified: 2025 September 30
// Description: Defines the Group model for the application.

class Group {
  int? id;
  String name;
  String? description;
  String color;
  String? icon; // Added icon property
  int sortOrder;
  DateTime? createdAt; // Added createdAt property

  Group({
    this.id,
    required this.name,
    this.description,
    this.color = 'blue', // Changed default to color name instead of hex
    this.icon,
    this.sortOrder = 0,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'sortOrder': sortOrder,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      color: map['color'] ?? 'blue',
      icon: map['icon'],
      sortOrder: map['sortOrder'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
    );
  }

  // Added copyWith method
  Group copyWith({
    int? id,
    String? name,
    String? description,
    String? color,
    String? icon,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
