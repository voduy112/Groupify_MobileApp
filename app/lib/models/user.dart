class User {
  String? id;
  String? username;
  String? email;
  String? password;
  String? phoneNumber;
  String? profilePicture;
  String? token;
  String? refreshToken;
  String? fcmToken = '';

  User({
    this.id,
    this.username,
    this.email,
    this.password,
    this.phoneNumber,
    this.profilePicture,
    this.token,
    this.refreshToken,
    this.fcmToken,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? json['id'];
    username = json['username'];
    email = json['email'];
    password = json['password'];
    phoneNumber = json['phoneNumber'];
    profilePicture = json['profilePicture'];
    token = json['token'];
    refreshToken = json['refreshToken'];
    fcmToken = json['fcmToken'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'token': token,
      'refreshToken': refreshToken,
      'fcmToken': fcmToken ?? '',
    };
  }
}
