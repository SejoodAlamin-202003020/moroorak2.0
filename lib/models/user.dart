class User {
  final String id;
  final String fullName;
  final String licenseNumber;
  final String phoneNumber;
  final String email;
  final String password;

  User({
    required this.id,
    required this.fullName,
    required this.licenseNumber,
    required this.phoneNumber,
    required this.email,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'],
      licenseNumber: json['license_number'],
      phoneNumber: json['phone'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'license_number': licenseNumber,
      'phone_number': phoneNumber,
      'email': email,
      'password': password,
    };
  }
}
