import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../models/doctor_model.dart';

/// Displays the detailed profile of a specific doctor.
class DoctorDetailScreen extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  // Helper method to build a statistic/overview stat
  Widget _buildOverviewStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
  
  // Helper method to build a detail row (e.g., Location, Fee)
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.secondary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(doctor.name),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Profile Header Section ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: doctor.profileImageUrl != null && doctor.profileImageUrl!.isNotEmpty
                        ? NetworkImage(doctor.profileImageUrl!)
                        : null,
                    child: doctor.profileImageUrl == null || doctor.profileImageUrl!.isEmpty
                        ? const Icon(Icons.person, size: 50, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    doctor.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    doctor.specialty,
                    style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            
            // --- Main Content Area ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Overview Stats Card
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildOverviewStat('Experience', '10+ yrs'), // Placeholder for dynamic data
                          _buildOverviewStat('Rating', doctor.rating.toStringAsFixed(1)),
                          _buildOverviewStat('Reviews', doctor.reviewsCount.toString()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 2. About Doctor (Bio)
                  const Text(
                    'About Doctor',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    doctor.bio,
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 25),

                  // 3. Practice Details
                  const Text(
                    'Practice Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 15),
                  _buildDetailRow(
                    Icons.location_on,
                    'Hospital/Clinic',
                    doctor.hospital ?? 'Private Practice',
                  ),
                  _buildDetailRow(
                    Icons.money,
                    'Consultation Fee',
                    currencyFormatter.format(doctor.consultationFee),
                  ),
                  
                  const SizedBox(height: 25),

                  // 4. Availability (Simplified)
                  const Text(
                    'Availability',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Typical available days:',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8.0,
                    children: doctor.availableDays.map((day) => Chip(
                      label: Text(day),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      labelStyle: const TextStyle(color: AppColors.primary),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // --- Persistent Booking Button ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to the Booking Screen, passing the doctor model
              Navigator.of(context).pushNamed(
                '/booking', 
                arguments: doctor
              );
            },
            child: const Text(
              'Book Appointment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}