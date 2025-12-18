import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final int yearsExp;
  final String location;
  final double distance;
  final String imagePath;

  const DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.yearsExp,
    required this.location,
    required this.distance,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        // 🔜 Later: open doctor details page
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            _DoctorInfoRow(
              name: name,
              specialty: specialty,
              rating: rating,
              yearsExp: yearsExp,
              location: location,
              distance: distance,
              imagePath: imagePath,
            ),
            const SizedBox(height: 14),
            _BookButton(
              onPressed: () {
                // 🔜 Hook booking flow here
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ================= DOCTOR INFO =================

class _DoctorInfoRow extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final int yearsExp;
  final String location;
  final double distance;
  final String imagePath;

  const _DoctorInfoRow({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.yearsExp,
    required this.location,
    required this.distance,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DoctorAvatar(imagePath: imagePath),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                specialty,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _RatingAndExperience(rating: rating, yearsExp: yearsExp),
              const SizedBox(height: 6),
              _LocationRow(location: location, distance: distance),
            ],
          ),
        ),
      ],
    );
  }
}

// ================= AVATAR =================

class _DoctorAvatar extends StatelessWidget {
  final String imagePath;

  const _DoctorAvatar({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        imagePath,
        width: 82,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 82,
          height: 100,
          color: Colors.grey.shade200,
          child: const Icon(Icons.person, size: 36, color: Colors.grey),
        ),
      ),
    );
  }
}

// ================= RATING =================

class _RatingAndExperience extends StatelessWidget {
  final double rating;
  final int yearsExp;

  const _RatingAndExperience({required this.rating, required this.yearsExp});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, size: 16, color: Colors.amber),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 13)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text('•', style: TextStyle(color: Colors.grey)),
        ),
        Text(
          '$yearsExp yrs experience',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }
}

// ================= LOCATION =================

class _LocationRow extends StatelessWidget {
  final String location;
  final double distance;

  const _LocationRow({required this.location, required this.distance});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '$location • ${distance.toStringAsFixed(1)} km',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ================= BOOK BUTTON =================

class _BookButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BookButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
          ),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Book Appointment',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
