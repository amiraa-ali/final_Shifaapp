import 'package:flutter/material.dart';
import 'details.dart';

class DoctorCard extends StatelessWidget {
  final String doctorId;
  final String name;
  final String specialty;
  final double rating;
  final int yearsExp;
  final String location;
  final double distance;
  final String? imageUrl;
  final double price;

  const DoctorCard({
    super.key,
    required this.doctorId,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.yearsExp,
    required this.location,
    required this.distance,
    this.imageUrl,
    required this.price,
  });

  void _openDoctorDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorDetailsPage(
          doctorId: doctorId,
          doctorName: name,
          specialty: specialty,
          location: location,
          price: price,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),

      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),

            blurRadius: 14,

            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(24),

          onTap: () => _openDoctorDetails(context),

          child: Padding(
            padding: const EdgeInsets.all(18),

            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    _buildDoctorImage(),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,

                                  maxLines: 1,

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    fontSize: 19,

                                    fontWeight: FontWeight.bold,

                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              _buildRatingChip(),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Text(
                            specialty,

                            style: TextStyle(
                              color: Colors.grey.shade600,

                              fontSize: 14,

                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 14),

                          _buildInfoRow(
                            Icons.work_outline,
                            '$yearsExp years experience',
                            Colors.blue,
                          ),

                          const SizedBox(height: 10),

                          _buildInfoRow(
                            Icons.location_on_outlined,
                            '$location • ${distance.toStringAsFixed(1)} km',
                            Colors.orange,
                          ),

                          const SizedBox(height: 14),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Text(
                                '${price.toStringAsFixed(0)} EGP',

                                style: const TextStyle(
                                  color: Colors.teal,

                                  fontWeight: FontWeight.bold,

                                  fontSize: 20,
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),

                                  borderRadius: BorderRadius.circular(12),
                                ),

                                child: const Text(
                                  'Available',

                                  style: TextStyle(
                                    color: Colors.green,

                                    fontWeight: FontWeight.bold,

                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,

                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),

                      gradient: const LinearGradient(
                        colors: [Color(0xff39ab4a), Color(0xff009f93)],

                        begin: Alignment.centerLeft,

                        end: Alignment.centerRight,
                      ),
                    ),

                    child: ElevatedButton(
                      onPressed: () => _openDoctorDetails(context),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,

                        shadowColor: Colors.transparent,

                        elevation: 0,

                        padding: const EdgeInsets.symmetric(vertical: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: const [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 18,
                          ),

                          SizedBox(width: 10),

                          Text(
                            'Book Appointment',

                            style: TextStyle(
                              fontSize: 16,

                              color: Colors.white,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorImage() {
    return Hero(
      tag: doctorId,

      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),

        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,

                width: 92,
                height: 120,

                fit: BoxFit.cover,

                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }

                  return _buildImageLoader();
                },

                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar();
                },
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildImageLoader() {
    return Container(
      width: 92,
      height: 120,

      decoration: BoxDecoration(
        color: Colors.grey.shade200,

        borderRadius: BorderRadius.circular(20),
      ),

      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 92,
      height: 120,

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff39ab4a), Color(0xff009f93)],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(20),
      ),

      child: const Icon(Icons.person, size: 48, color: Colors.white),
    );
  }

  Widget _buildRatingChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.12),

        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),

          const SizedBox(width: 4),

          Text(
            rating.toStringAsFixed(1),

            style: const TextStyle(
              fontWeight: FontWeight.bold,

              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),

          decoration: BoxDecoration(
            color: color.withOpacity(0.12),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(icon, size: 18, color: color),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            text,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
