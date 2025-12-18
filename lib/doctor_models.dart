class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final double price;
  final String location;
  final double rating;
  final int yearsExp;
  final bool isActive; // Added to match Firebase logic

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.price,
    required this.location,
    required this.rating,
    required this.yearsExp,
    required this.isActive,
  });

  factory DoctorModel.fromMap(String id, Map<String, dynamic> data) {
    return DoctorModel(
      id: id,
      name: data['name'] ?? 'Doctor',
      specialty: data['specialty'] ?? 'General',
      price: (data['price'] ?? 0).toDouble(),
      location: data['location'] ?? 'Unknown',
      rating: (data['rating'] ?? 0).toDouble(),
      yearsExp: (data['yearsExp'] ?? 0),
      isActive: data['isActive'] ?? true,
    );
  }
}
