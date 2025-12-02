import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';

/// Screen to view and manage all user appointments (Upcoming, Past, Cancelled).
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Filters appointments based on the provided status (Upcoming, Past, Cancelled).
  List<AppointmentModel> _filterAppointments(List<AppointmentModel> allAppointments, String status) {
    final now = DateTime.now();
    
    if (status == 'Upcoming') {
      return allAppointments.where((app) => 
        app.status == 'Confirmed' && app.appointmentDateTime.isAfter(now)
      ).toList()..sort((a, b) => a.appointmentDateTime.compareTo(b.appointmentDateTime)); // Sort by nearest date
    } else if (status == 'Past') {
      return allAppointments.where((app) => 
        app.status == 'Confirmed' && app.appointmentDateTime.isBefore(now)
      ).toList()..sort((a, b) => b.appointmentDateTime.compareTo(a.appointmentDateTime)); // Sort by newest date
    } else if (status == 'Cancelled') {
      return allAppointments.where((app) => app.status == 'Cancelled').toList();
    }
    return [];
  }

  /// Shows a confirmation dialog before cancelling an appointment.
  Future<void> _showCancelDialog(BuildContext context, AppointmentModel appointment) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Appointment?'),
          content: Text('Are you sure you want to cancel your appointment with ${appointment.doctorName} on ${DateFormat('MMM d, yyyy').format(appointment.appointmentDateTime)}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No, Keep it', style: TextStyle(color: AppColors.secondary)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Yes, Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                Provider.of<AppointmentProvider>(context, listen: false)
                    .cancelAppointment(appointment.id)
                    .then((_) {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Appointment successfully cancelled.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }).catchError((e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cancellation failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Error loading appointments: ${provider.errorMessage}',
                    textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              ),
            );
          }
          
          final allAppointments = provider.userAppointments;

          return TabBarView(
            controller: _tabController,
            children: [
              // Upcoming Appointments Tab
              _buildAppointmentList(context, _filterAppointments(allAppointments, 'Upcoming')),
              
              // Past Appointments Tab
              _buildAppointmentList(context, _filterAppointments(allAppointments, 'Past')),
              
              // Cancelled Appointments Tab
              _buildAppointmentList(context, _filterAppointments(allAppointments, 'Cancelled')),
            ],
          );
        },
      ),
    );
  }

  /// Builds the list view for a filtered set of appointments.
  Widget _buildAppointmentList(BuildContext context, List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return const Center(
        child: Text(
          'No appointments found for this category.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15.0),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final isUpcoming = appointment.status == 'Confirmed' && appointment.appointmentDateTime.isAfter(DateTime.now());
        
        return AppointmentCard(
          appointment: appointment,
          onCancel: isUpcoming ? () => _showCancelDialog(context, appointment) : null,
        );
      },
    );
  }
}

/// Widget to display a single appointment's details.
class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onCancel;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(appointment.status);
    final isCancelled = appointment.status == 'Cancelled';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Doctor Name and Specialty ---
            Row(
              children: [
                const Icon(Icons.person_pin, color: AppColors.secondary, size: 24),
                const SizedBox(width: 10),
                Text(
                  appointment.doctorName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.secondary),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment.status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              appointment.doctorSpecialty,
              style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            
            const Divider(height: 25),

            // --- Date and Time ---
            _buildDetailRow(
              Icons.calendar_today, 
              DateFormat('EEEE, MMM d, yyyy').format(appointment.appointmentDateTime),
            ),
            _buildDetailRow(
              Icons.access_time, 
              DateFormat('hh:mm a').format(appointment.appointmentDateTime),
            ),
            
            const SizedBox(height: 10),

            // --- Reason for Visit ---
            if (!isCancelled)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reason:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            
            const SizedBox(height: 15),

            // --- Action Button (Cancel) ---
            if (onCancel != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text('Cancel Appointment', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: Colors.red, width: 1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Helper for status colors
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      case 'Pending':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  // Helper for detail rows
  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 15, color: AppColors.secondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}