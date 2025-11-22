class Investigator {
  final String id;
  final String investigatorId;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final DateTime createdAt;

  String get name => '$firstName $lastName';
  String get department => 'Traffic Department'; // Default department
  String get role => 'Investigator'; // Default role
  String get phone => '+249000000000'; // Placeholder phone

  Investigator({
    required this.id,
    required this.investigatorId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  factory Investigator.fromJson(Map<String, dynamic> json) {
    return Investigator(
      id: json['id'],
      investigatorId: json['id_number'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      password: json['password'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_number': investigatorId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
