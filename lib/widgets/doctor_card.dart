import 'package:flutter/material.dart';
import '../models/doctor_model.dart';

class AppColors {
  static const Color primary = Color(0xFF1ABC9C);
  static const Color secondary = Color(0xFF34495E);
  static const Color starColor = Color(0xFFFFC107);
}

class DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onTap;

  const DoctorCard({super.key, required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Check if the profile image URL is not null and not empty
    final bool hasImage = doctor.profileImageUrl != null && doctor.profileImageUrl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Image (Placeholder)
              CircleAvatar(
                radius: 40,
                // Using withAlpha to handle the deprecation warning
                backgroundColor: AppColors.primary.withAlpha((255 * 0.1).round()), 
                // Using profileImageUrl from your model
                backgroundImage: hasImage
                    ? NetworkImage(doctor.profileImageUrl!)
                    : null,
                child: !hasImage
                    ? const Icon(Icons.person, size: 40, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Uses 'name' getter
                    Text(
                      'Dr. ${doctor.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Uses 'specialty' getter
                    Text(
                      doctor.specialty,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.starColor, size: 16),
                        const SizedBox(width: 4),
                        // Uses 'reviewsCount' getter
                        Text(
                          '${doctor.rating.toStringAsFixed(1)} (${doctor.reviewsCount} reviews)',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fee: \$${doctor.consultationFee.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}