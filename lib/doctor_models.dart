class DoctorModel {
  final String id;

  final String name;

  final String specialty;

  final double price;

  final String location;

  final double rating;

  final int yearsExp;

  final bool isActive;

  final String? imageUrl;

  final String? about;

  final String? university;

  final String? certificate;

  final String? phone;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.price,
    required this.location,
    required this.rating,
    required this.yearsExp,
    required this.isActive,
    this.imageUrl,
    this.about,
    this.university,
    this.certificate,
    this.phone,
  });

  // =========================
  // FROM JSON
  // =========================
  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['_id'] ?? '',

      name: json['name'] ?? 'Doctor',

      specialty: json['specialization'] ?? 'General',

      price: (json['fees'] ?? 0).toDouble(),

      location: json['clinicLocation'] ?? 'Unknown',

      rating: (json['rating'] ?? 4.5).toDouble(),

      yearsExp: json['yearsExperience'] ?? 1,

      isActive: json['isActive'] ?? true,

      imageUrl: json['profileImage'],

      about: json['about'],

      university: json['university'],

      certificate: json['certificate'],

      phone: json['phone'],
    );
  }

  // =========================
  // TO JSON
  // =========================
  Map<String, dynamic> toJson() {
    return {
      '_id': id,

      'name': name,

      'specialization': specialty,

      'fees': price,

      'clinicLocation': location,

      'rating': rating,

      'yearsExperience': yearsExp,

      'isActive': isActive,

      'profileImage': imageUrl,

      'about': about,

      'university': university,

      'certificate': certificate,

      'phone': phone,
    };
  }
}
