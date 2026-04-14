import 'package:ai_meal_planner/core/network/api_endpoints.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.isEmailVerified = false,
    this.isPremium = false,
    this.isActive = true,
    this.profileImageUrl,
    this.passwordChangedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final bool isEmailVerified;
  final bool isPremium;
  final bool isActive;
  final String? profileImageUrl;
  final DateTime? passwordChangedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String? get resolvedProfileImageUrl {
    final value = profileImageUrl?.trim() ?? '';
    if (value.isEmpty) {
      return null;
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '${ApiEndpoints.baseUrl}$value';
    }

    return value;
  }

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    bool? isEmailVerified,
    bool? isPremium,
    bool? isActive,
    String? profileImageUrl,
    bool clearProfileImageUrl = false,
    DateTime? passwordChangedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPremium: isPremium ?? this.isPremium,
      isActive: isActive ?? this.isActive,
      profileImageUrl: clearProfileImageUrl
          ? null
          : profileImageUrl ?? this.profileImageUrl,
      passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'isPremium': isPremium,
      'isActive': isActive,
      'profileImageUrl': profileImageUrl,
      'passwordChangedAt': passwordChangedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isEmailVerified: json['isEmailVerified'] == true,
      isPremium: json['isPremium'] == true,
      isActive: json['isActive'] != false,
      profileImageUrl: json['profileImageUrl']?.toString(),
      passwordChangedAt: _parseDateTime(json['passwordChangedAt']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw);
  }
}
