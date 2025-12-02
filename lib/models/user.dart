import 'types.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String firstName;
  final String lastName;
  final String phone;
  final bool isActive;
  final DateTime createdAt;
  final String? profileImageUrl;
  final Location? defaultLocation;
  final List<String> roles;
  final List<String> allowedApps;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.firstName = '',
    this.lastName = '',
    required this.phone,
    this.isActive = true,
    required this.createdAt,
    this.profileImageUrl,
    this.defaultLocation,
    this.roles = const [],
    this.allowedApps = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String string(dynamic value) => value?.toString() ?? '';
    List<String> stringList(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      if (value is String && value.isNotEmpty) {
        return value
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return const [];
    }

    final firstName = string(
      json['first_name'] ?? json['firstName'] ?? json['given_name'],
    );
    final lastName = string(
      json['last_name'] ?? json['lastName'] ?? json['family_name'],
    );
    final combinedName = string(json['name'] ?? json['full_name']);
    final derivedName = combinedName.isNotEmpty
        ? combinedName
        : '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : string(json['email']).split('@').first.replaceAll('.', ' ');

    final allowedAppsRaw =
        json['allowed_apps'] ?? json['allowedApps'] ?? json['apps'];
    final rolesRaw = json['roles'] ?? json['user_roles'] ?? json['role'];

    return User(
      id: string(json['id'] ?? json['uuid'] ?? json['user_id']),
      email: string(json['email']),
      name: derivedName,
      firstName: firstName,
      lastName: lastName,
      phone: string(
        json['phone'] ?? json['phone_number'] ?? json['phoneNumber'],
      ),
      isActive: json['is_active'] ?? json['isActive'] ?? json['active'] ?? true,
      createdAt:
          DateTime.tryParse(
            json['created_at'] ??
                json['createdAt'] ??
                json['date_joined'] ??
                '',
          ) ??
          DateTime.now(),
      profileImageUrl:
          json['profile_image_url'] ?? json['avatar_url'] ?? json['photo_url'],
      defaultLocation: json['default_location'] != null
          ? Location.fromJson(json['default_location'])
          : json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
      roles: stringList(rolesRaw),
      allowedApps: stringList(allowedAppsRaw),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'profile_image_url': profileImageUrl,
      'default_location': defaultLocation?.toJson(),
      'roles': roles,
      'allowed_apps': allowedApps,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? firstName,
    String? lastName,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
    String? profileImageUrl,
    Location? defaultLocation,
    List<String>? roles,
    List<String>? allowedApps,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      roles: roles ?? List<String>.from(this.roles),
      allowedApps: allowedApps ?? List<String>.from(this.allowedApps),
    );
  }

  String get displayFirstName {
    if (firstName.isNotEmpty) return firstName;
    if (name.isNotEmpty && name.contains(' ')) {
      return name.split(' ').first;
    }
    if (name.isNotEmpty) return name;
    return email.split('@').first;
  }

  String get displayName => name.isNotEmpty ? name : email;
}
