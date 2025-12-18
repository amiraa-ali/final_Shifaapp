class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String location;
  final double rating;
  final int yearsExperience;
  final double price;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.rating,
    required this.yearsExperience,
    required this.price,
  });

  factory Doctor.fromMap(String id, Map<String, dynamic> data) {
    return Doctor(
      id: id,
      // Mapping Firestore keys to Model properties
      name: data['name'] ?? 'Doctor',
      specialty: data['specialty'] ?? 'General',
      location: data['location'] ?? 'Clinic',
      rating: (data['rating'] ?? 0.0).toDouble(),
      yearsExperience: data['yearsExp'] ?? 0,
      price: (data['price'] ?? 0.0).toDouble(),
    );
  }
}
