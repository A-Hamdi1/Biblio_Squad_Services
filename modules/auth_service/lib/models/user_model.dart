class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String role;

  // Définir des constantes pour les rôles disponibles
  static const String ROLE_USER = 'user';
  static const String ROLE_AUTHOR = 'author';
  static const String ROLE_ADMIN = 'admin';

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      role: map['role'],
    );
  }

  bool canAccessBarcodeService() {
    return role == ROLE_USER || role == ROLE_ADMIN || role == ROLE_AUTHOR;
  }

  bool canAccessDocumentScanService() {
    return role == ROLE_ADMIN || role == ROLE_AUTHOR;
  }

  bool canAccessGestionUsersService() {
    return role == ROLE_ADMIN;
  }

  bool canAccessOcrService() {
    return role == ROLE_USER || role == ROLE_ADMIN || role == ROLE_AUTHOR;
  }

  bool canAccessTranslationService() {
    return role == ROLE_USER || role == ROLE_ADMIN || role == ROLE_AUTHOR;
  }

  bool canAccessSmartReplyService() {
    return role == ROLE_USER || role == ROLE_ADMIN || role == ROLE_AUTHOR;
  }
}
