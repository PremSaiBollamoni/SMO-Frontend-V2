/// Login request model
class LoginRequest {
  final String loginid;
  final String password;

  LoginRequest({required this.loginid, required this.password});

  Map<String, dynamic> toJson() {
    return {'loginid': loginid, 'password': password};
  }
}
