class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isCompleted;
  final bool isNeedStorage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isCompleted,
    required this.isNeedStorage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isCompleted: json['isCompleted'] as bool,
      isNeedStorage: json['isNeedStorage'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isCompleted': isCompleted,
      'isNeedStorage': isNeedStorage,
    };
  }

  // Helper method to map to UserModel for application use
  UserModel toUserModel() {
    return UserModel(
      id: id,
      fullName: name,
      email: email,
      phone: '', // Phone may come from profile details
      isEmailVerified: true,
      isProfileComplete: isCompleted,
      role: role,
      isNeedStorage: isNeedStorage,
    );
  }
}

// Extended model for application use (to maintain compatibility with existing code)
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final bool isEmailVerified;
  final bool isProfileComplete;
  final String? role;
  final bool isNeedStorage;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    this.isEmailVerified = false,
    this.isProfileComplete = false,
    this.role,
    this.isNeedStorage = false,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    bool? isEmailVerified,
    bool? isProfileComplete,
    String? role,
    bool? isNeedStorage,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      role: role ?? this.role,
      isNeedStorage: isNeedStorage ?? this.isNeedStorage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'isEmailVerified': isEmailVerified,
      'isProfileComplete': isProfileComplete,
      'role': role,
      'isNeedStorage': isNeedStorage,
    };
  }
}