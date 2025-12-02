import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';

class AppColors {
  static const Color primary = Color(0xFF1ABC9C);
  static const Color secondary = Color(0xFF34495E);
}

class AppointmentTile extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onCancel;
  final bool showCancelButton;

  const AppointmentTile({
    super.key,
    required this.appointment,
    required this.onCancel,
    this.showCancelButton = true,
  });

  // Helper to get color based on the status STRING (e.g., 'upcoming', 'cancelled')
  Color _getStatusColor() {
    // Check status string (case-insensitive) as the model uses String for status.
    switch (appointment.status.toLowerCase()) {
      case 'confirmed':
      case 'upcoming':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'completed':
        return AppColors.secondary;
      case 'cancelled':
        return Colors.red.shade600;
      default:
        return Colors.grey;
    }
  }

  // Helper to get icon based on the status STRING
  IconData _getStatusIcon() {
    switch (appointment.status.toLowerCase()) {
      case 'confirmed':
      case 'upcoming':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.access_time;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using the correct property name: 'appointmentDateTime'
    final date = DateFormat('EEE, MMM d, yyyy').format(appointment.appointmentDateTime);
    final time = DateFormat('h:mm a').format(appointment.appointmentDateTime);
    
    // Determine if cancellation is allowed based on status string
    final isCancellable = appointment.status.toLowerCase() == 'pending' || 
                          appointment.status.toLowerCase() == 'confirmed' ||
                          appointment.status.toLowerCase() == 'upcoming';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Name 
            Text(
              'Dr. ${appointment.doctorName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 4),
            // Specialty: AppointmentModel does not store specialty, so display a default.
            const Text(
              'Specialty N/A (Detail available on Doctor Profile)', 
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(height: 20),
            
            // Date and Time
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                ),
                const SizedBox(width: 15),
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                // Fixed usage of withOpacity
                color: _getStatusColor().withOpacity(0.15), 
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getStatusIcon(), size: 16, color: _getStatusColor()),
                  const SizedBox(width: 6),
                  // Fixed to use status string directly
                  Text(
                    appointment.status.toUpperCase(), 
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Button (if applicable, e.g., Cancel)
            if (showCancelButton && isCancellable)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Cancel Appointment'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}