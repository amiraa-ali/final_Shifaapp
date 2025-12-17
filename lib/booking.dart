import 'package:flutter/material.dart';
import 'patient_home_screen.dart';
import 'Services/firebase_services.dart';
class BookAppointmentPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String clinicLocation;
  final String serviceType;
  final String totalAmount;

  const BookAppointmentPage({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.clinicLocation,
    required this.serviceType,
    required this.totalAmount,
  });

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final FirebaseServices _firebaseServices = FirebaseServices();

  String selectedTime = "04:30 PM";
  DateTime selectedDate = DateTime.now();
  int currentStep = 1;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();

  final List<String> times = [
    "03:00 PM",
    "03:30 PM",
    "04:00 PM",
    "04:30 PM",
    "05:00 PM",
    "05:30 PM",
    "06:00 PM",
    "06:30 PM",
  ];

  @override
  void dispose() {
    cardNumberController.dispose();
    expiryDateController.dispose();
    cvcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(),
          const SizedBox(height: 20),
          Expanded(child: _buildStepContent()),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    if (currentStep == 1) return _buildDateTimeStep();
    if (currentStep == 2) return _buildPaymentStep();
    return _buildSummaryStep();
  }

  Widget _buildDateTimeStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Date",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) setState(() => selectedDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 10),
                  Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            "Available Time",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: times.map((time) {
              final active = time == selectedTime;
              return GestureDetector(
                onTap: () => setState(() => selectedTime = time),
                child: Container(
                  width: 130,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xff14B8A6)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      color: active ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          _buildPrimaryButton(
            text: "Continue",
            onPressed: () => setState(() => currentStep = 2),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Payment",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: cardNumberController,
                  decoration: const InputDecoration(labelText: "Card Number"),
                  validator: (v) =>
                      v!.length < 16 ? "Invalid card number" : null,
                ),
                TextFormField(
                  controller: expiryDateController,
                  decoration: const InputDecoration(labelText: "MM/YY"),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: cvcController,
                  decoration: const InputDecoration(labelText: "CVC"),
                  validator: (v) => v!.length != 3 ? "Invalid CVC" : null,
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildPrimaryButton(
            text: "Continue",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() => currentStep = 3);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.doctorName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(widget.doctorSpecialty),
          const SizedBox(height: 15),
          Text(
            "Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
          ),
          Text("Time: $selectedTime"),
          const Spacer(),
          _buildPrimaryButton(
            text: "Confirm Appointment",
            onPressed: _confirmBooking,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking() async {
    try {
      await _firebaseServices.bookAppointment(
        doctorId: widget.doctorId,
        doctorName: widget.doctorName,
        doctorSpecialty: widget.doctorSpecialty,
        date: selectedDate,
        time: selectedTime,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Appointment Requested"),
          content: const Text("Your appointment request has been sent."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => PatientHomeScreen()),
                  (_) => false,
                );
              },
              child: const Text("Back to Home"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking failed")),
      );
    }
  }

  Widget _buildAppBar() {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff39ab4a), Color(0xff009f93)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const SafeArea(
        child: Center(
          child: Text(
            "Book Appointment",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff009f93),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
