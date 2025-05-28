class User {
  String? id;
  String? username;
  String? email;
  String? phoneNumber;
  String? profilePicture;
  String? bio;
  String? accessToken;
  String? refreshToken;
  String? fcmToken = '';

  User({
    this.id,
    this.username,
    this.email,
    this.phoneNumber,
    this.profilePicture,
    this.bio,
    this.accessToken,
    this.refreshToken,
    this.fcmToken,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? json['id'];
    username = json['username'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    profilePicture = json['profilePicture'];
    bio = json['bio'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    fcmToken = json['fcmToken'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'bio': bio,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'fcmToken': fcmToken ?? '',
    };
  }
}
