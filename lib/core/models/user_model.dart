class UserModel {
  final String uid;
  final String email;
  final String username;
  final String fullName;
  final String phoneNumber;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.fullName,
    required this.phoneNumber,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
    );
  }
}