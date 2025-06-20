class AppUser {
  final String email;
  final String name;
  final String phone;
  final String uid;
  final String? profileImageDocId;

  AppUser({
    required this.email,
    required this.name,
    required this.phone,
    required this.uid,
    this.profileImageDocId,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      uid: data['uid'] ?? '',
      profileImageDocId: data['profileImageDocId'],
    );
  }
}