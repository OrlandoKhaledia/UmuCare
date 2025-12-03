import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../models/doctor_model.dart';
import '../../providers/appointment_provider.dart';

/// Screen to select date, time, and reason for booking an appointment.
class BookingScreen extends StatefulWidget {
  final DoctorModel doctor;

  const BookingScreen({super.key, required this.doctor});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  final TextEditingController _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Placeholder time slots for a full day (8 AM to 4 PM)
  final List<String> _timeSlots = [
    '08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM', 
    '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  /// Handles the appointment booking process.
  Future<void> _handleBooking() async {
    if (!_formKey.currentState!.validate() || 
        _selectedDate == null || 
        _selectedTimeSlot == null) {
      // Show error if selection is incomplete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date, time, and provide a reason.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Combine selected date and time slot into a final DateTime object
    final timeParts = _selectedTimeSlot!.split(RegExp(r'[:\s]'));
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final ampm = timeParts[2];
    
    if (ampm == 'PM' && hour != 12) {
      hour += 12;
    } else if (ampm == 'AM' && hour == 12) {
      hour = 0; // Midnight case
    }
    
    final appointmentDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      hour,
      minute,
    );

    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

    try {
      await appointmentProvider.bookAppointment(
        doctor: widget.doctor,
        dateTime: appointmentDateTime,
        reason: _reasonController.text.trim(),
      );
      
      // Success feedback and navigation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment successfully booked!'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate back to Home or push to Appointments screen
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed('/appointments');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: ${appointmentProvider.errorMessage ?? e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Opens the date picker with safe bounds and resets time slot on date change.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime safeFirstDate = DateTime(now.year, now.month, now.day);
    final DateTime safeLastDate = safeFirstDate.add(const Duration(days: 365));
    final DateTime initialDate = _selectedDate ?? safeFirstDate;

    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: safeFirstDate,
        lastDate: safeLastDate,
        barrierDismissible: true,
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                onSurface: AppColors.secondary,
                surface: Colors.white,
              ),
              datePickerTheme: DatePickerThemeData(
                backgroundColor: Colors.white,
                headerBackgroundColor: AppColors.primary,
                headerForegroundColor: Colors.white,
                dayOverlayColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.2)),
                todayBorder: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            child: child ?? const SizedBox(),
          );
        },
      );

      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
          _selectedTimeSlot = null;
        });
      }
    } catch (e) {
      print('Error opening date picker: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final appointmentProvider = context.watch<AppointmentProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // --- Doctor Header Card ---
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: doctor.profileImageUrl != null && doctor.profileImageUrl!.isNotEmpty
                            ? NetworkImage(doctor.profileImageUrl!)
                            : null,
                        child: doctor.profileImageUrl == null || doctor.profileImageUrl!.isEmpty
                            ? const Icon(Icons.person, size: 30, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              doctor.specialty,
                              style: const TextStyle(color: AppColors.primary, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        currencyFormatter.format(doctor.consultationFee),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // --- Date Selection ---
              const Text(
                '1. Select Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null 
                            ? 'Choose a date (Mon, Tue, Wed...)' 
                            : DateFormat('EEEE, MMM d, yyyy').format(_selectedDate!),
                        style: TextStyle(
                            fontSize: 16,
                            color: _selectedDate == null ? Colors.grey : AppColors.secondary,
                            fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.calendar_month, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // --- Time Slot Selection ---
              const Text(
                '2. Select Time Slot',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _timeSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;
                  return ChoiceChip(
                    label: Text(slot),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.secondary,
                      fontWeight: FontWeight.w600
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedTimeSlot = selected ? slot : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),

              // --- Reason for Appointment ---
              const Text(
                '3. Reason for Visit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe your symptoms or reason for visit...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 10) {
                    return 'Please provide a detailed reason (min 10 characters).';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      // --- Final Booking Button ---
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: appointmentProvider.isLoading ? null : _handleBooking,
            child: appointmentProvider.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3.0,
                    ),
                  )
                : Text(
                    'Confirm Booking - ${currencyFormatter.format(doctor.consultationFee)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}