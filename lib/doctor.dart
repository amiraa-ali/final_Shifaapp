class Doctor {
  final String id;

  final String name;

  final String specialty;

  final String location;

  final double rating;

  final int yearsExperience;

  final double price;

  final String? imageUrl;

  final String? about;

  final String? university;

  final String? certificate;

  final String? phone;

  final bool isActive;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.rating,
    required this.yearsExperience,
    required this.price,
    this.imageUrl,
    this.about,
    this.university,
    this.certificate,
    this.phone,
    this.isActive = true,
  });

  // =========================
  // FROM JSON
  // =========================
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] ?? '',

      name: json['name'] ?? 'Doctor',

      specialty: json['specialization'] ?? 'General',

      location: json['clinicLocation'] ?? 'Clinic',

      rating: (json['rating'] ?? 4.5).toDouble(),

      yearsExperience: json['yearsExperience'] ?? 1,

      price: (json['fees'] ?? 0).toDouble(),

      imageUrl: json['profileImage'],

      about: json['about'],

      university: json['university'],

      certificate: json['certificate'],

      phone: json['phone'],

      isActive: json['isActive'] ?? true,
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

      'clinicLocation': location,

      'rating': rating,

      'yearsExperience': yearsExperience,

      'fees': price,

      'profileImage': imageUrl,

      'about': about,

      'university': university,

      'certificate': certificate,

      'phone': phone,

      'isActive': isActive,
    };
  }
}
