class User {
  String? id;
  String? username;
  String? email;
  String? phoneNumber;
  String? profilePicture;
  String? token;
  String? refreshToken;

  User({
    this.id,
    this.username,
    this.email,
    this.phoneNumber,
    this.profilePicture,
    this.token,
    this.refreshToken,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    profilePicture = json['profilePicture'];
    token = json['token'];
    refreshToken = json['refreshToken'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'token': token,
      'refreshToken': refreshToken,
    };
  }
}
