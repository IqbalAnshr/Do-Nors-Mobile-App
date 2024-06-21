class DonationRequest {
  final int id;
  final String city;
  final String hospital;
  final String organType;
  final String phoneNumber;
  final String note;
  final int userId;
  final String createdAt;
  final String updatedAt;
  final User user;

  DonationRequest({
    required this.id,
    required this.city,
    required this.hospital,
    required this.organType,
    required this.phoneNumber,
    required this.note,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory DonationRequest.fromJson(Map<String, dynamic> json) {
    return DonationRequest(
      id: json['id'],
      city: json['city'],
      hospital: json['hospital'],
      organType: json['organType'],
      phoneNumber: json['phoneNumber'],
      note: json['note'],
      userId: json['userId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      user: User.fromJson(json['User']),
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
