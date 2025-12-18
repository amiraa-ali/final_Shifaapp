import 'package:flutter/material.dart';
import 'package:shifa/patient_home_screen.dart';
import 'package:shifa/Services/firebase_services.dart';

// =========================================================
// Book Appointment Page with Firebase Integration
// =========================================================
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

  // =========================================================
  // STATE MANAGEMENT (Date & Time)
  // =========================================================
  String selectedTime = "04:30 PM";
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  int currentStep = 1;

  int displayCount = 5;
  int startIndex = 0;
  int maxDays = 30;

  final List<String> times = [
    "03:00 PM",
    "03:30 PM",
    "04:00 PM",
    "04:30 PM",
    "05:00 PM",
    "05:30 PM",
    "06:00 PM",
    "06:30 PM",
    "07:00 PM",
    "07:30 PM",
    "08:00 PM",
  ];

  // =========================================================
  // STATE MANAGEMENT (Payment)
  // =========================================================
  bool cardSelected = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();

  // =========================================================
  // BOOKING INFORMATION
  // =========================================================
  late String doctorId;
  late String doctorName;
  late String doctorSpecialty;
  late String clinicLocation;
  late String serviceType;
  late String totalAmount;
  String paymentMethod = "Credit Card";

  @override
  void initState() {
    super.initState();
    doctorId = widget.doctorId;
    doctorName = widget.doctorName;
    doctorSpecialty = widget.doctorSpecialty;
    clinicLocation = widget.clinicLocation;
    serviceType = widget.serviceType;
    totalAmount = widget.totalAmount;

    centerSelectedDate(selectedDate);
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    expiryDateController.dispose();
    cvcController.dispose();
    super.dispose();
  }

  // =========================================================
  // FIREBASE - CREATE APPOINTMENT
  // =========================================================
  Future<void> _confirmAppointment() async {
    final currentUserId = _firebaseServices.getCurrentUserId();

    if (currentUserId == null) {
      _showErrorDialog("You must be logged in to book an appointment");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Create appointment in Firebase
      String? appointmentId = await _firebaseServices.createAppointment(
        patientId: currentUserId,
        doctorId: doctorId,
        appointmentDate: selectedDate,
        appointmentTime: selectedTime,
        serviceType: serviceType,
        fees: double.parse(totalAmount),
        paymentMethod: paymentMethod,
        clinicLocation: clinicLocation,
        doctorName: doctorName,
        doctorSpecialty: doctorSpecialty,
      );

      if (appointmentId != null) {
        // Book the time slot
        await _firebaseServices.bookTimeSlot(
          doctorId: doctorId,
          date: selectedDate,
          time: selectedTime,
        );

        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        if (mounted) {
          _showErrorDialog("Failed to create appointment. Please try again.");
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog("Failed to book appointment: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Appointment Confirmed"),
        content: const Text("Your appointment has been successfully booked!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
                (route) => false,
              );
            },
            child: const Text("Back to Home"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // HELPER FUNCTIONS (Date & Time)
  // =========================================================
  List<DateTime> get dates =>
      List.generate(maxDays, (i) => DateTime.now().add(Duration(days: i)));

  String dayFormat(DateTime date) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[date.weekday - 1];
  }

  String dateFormat(DateTime date) {
    return date.day.toString().padLeft(2, '0');
  }

  void centerSelectedDate(DateTime date) {
    int center = displayCount ~/ 2;
    startIndex = dates.indexOf(date) - center;
    if (startIndex < 0) startIndex = 0;
    if (startIndex + displayCount > dates.length) {
      startIndex = dates.length - displayCount;
    }
  }

  // =========================================================
  // HELPER WIDGETS (Payment Step)
  // =========================================================
  Widget _buildPaymentOption({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    const activeColor = Color(0xff14B8A6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? activeColor : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? activeColor : Colors.grey,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          const Text(
            "Credit card details",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          _buildInputField(
            controller: cardNumberController,
            hint: "0000 0000 0000 0000",
            icon: Icons.credit_card,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Card number required";
              }
              if (value.replaceAll(" ", "").length != 16) {
                return "Card number must be 16 digits";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: expiryDateController,
                  hint: "MM/YY",
                  icon: Icons.calendar_month,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Expiry required";
                    }
                    final regex = RegExp(r"^(0[1-9]|1[0-2])\/\d{2}$");
                    if (!regex.hasMatch(value)) {
                      return "Invalid date format (MM/YY)";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInputField(
                  controller: cvcController,
                  hint: "CVC",
                  icon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "CVC required";
                    }
                    if (value.length != 3) {
                      return "CVC must be 3 digits";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xff14B8A6)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xff14B8A6), width: 2),
        ),
      ),
      validator: validator,
    );
  }

  // =========================================================
  // BUILD METHOD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Book Appointment",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff39ab4a), Color(0xff009f93)],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress Indicator
                _buildProgressIndicator(),

                // Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: currentStep == 1
                        ? _buildDateTimeStep()
                        : currentStep == 2
                        ? _buildPaymentStep()
                        : _buildSummaryStep(),
                  ),
                ),

                // Navigation Buttons
                _buildNavigationButtons(),
              ],
            ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepCircle(1, "Date & Time"),
          _buildStepLine(),
          _buildStepCircle(2, "Payment"),
          _buildStepLine(),
          _buildStepCircle(3, "Summary"),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    bool isActive = step == currentStep;
    bool isCompleted = step < currentStep;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isCompleted
                ? const Color(0xff14B8A6)
                : Colors.grey.shade300,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    "$step",
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xff14B8A6) : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 40,
      height: 2,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.only(bottom: 25),
    );
  }

  // =========================================================
  // STEP 1: DATE & TIME
  // =========================================================
  Widget _buildDateTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Date",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Date Selector
        SizedBox(
          height: 100,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  if (startIndex > 0) {
                    setState(() => startIndex--);
                  }
                },
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayCount,
                  itemBuilder: (context, i) {
                    int actualIndex = startIndex + i;
                    if (actualIndex >= dates.length) return const SizedBox();
                    DateTime date = dates[actualIndex];
                    bool isSelected =
                        date.day == selectedDate.day &&
                        date.month == selectedDate.month &&
                        date.year == selectedDate.year;

                    return GestureDetector(
                      onTap: () => setState(() => selectedDate = date),
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xff14B8A6)
                              : const Color(0xffF2F4F7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayFormat(date),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              dateFormat(date),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  if (startIndex + displayCount < dates.length) {
                    setState(() => startIndex++);
                  }
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
        const Text(
          "Select Time",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Time Selector
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: times
              .map((time) => _buildTimeChip(time, time == selectedTime))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTimeChip(String time, bool active) {
    return GestureDetector(
      onTap: () => setState(() => selectedTime = time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xff14B8A6) : const Color(0xffF2F4F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // STEP 2: PAYMENT
  // =========================================================
  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Method",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildPaymentOption(
          title: "Credit / Debit Card",
          selected: cardSelected,
          onTap: () => setState(() {
            cardSelected = true;
            paymentMethod = "Credit Card";
          }),
        ),
        if (cardSelected) _buildCardForm(),
        const SizedBox(height: 10),
        _buildPaymentOption(
          title: "Cash",
          selected: !cardSelected,
          onTap: () => setState(() {
            cardSelected = false;
            paymentMethod = "Cash";
          }),
        ),
      ],
    );
  }

  // =========================================================
  // STEP 3: SUMMARY
  // =========================================================
  Widget _buildSummaryStep() {
    String formattedDate =
        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
    const cardPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    const titleStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    const valueStyle = TextStyle(color: Colors.grey, fontSize: 16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Booking Summary",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xff009f93),
          ),
        ),
        const SizedBox(height: 25),

        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 15),
          child: Padding(
            padding: cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Doctor", style: titleStyle),
                const SizedBox(height: 5),
                Text("$doctorName ($doctorSpecialty)", style: valueStyle),
              ],
            ),
          ),
        ),

        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 15),
          child: Padding(
            padding: cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Clinic", style: titleStyle),
                const SizedBox(height: 5),
                Text(clinicLocation, style: valueStyle),
              ],
            ),
          ),
        ),

        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 15),
          child: Padding(
            padding: cardPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Date", style: titleStyle),
                    const SizedBox(height: 5),
                    Text(formattedDate, style: valueStyle),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Time", style: titleStyle),
                    const SizedBox(height: 5),
                    Text(selectedTime, style: valueStyle),
                  ],
                ),
              ],
            ),
          ),
        ),

        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Payment Method", style: titleStyle),
                const SizedBox(height: 5),
                Text(paymentMethod, style: valueStyle),
                const SizedBox(height: 10),
                const Text("Total Amount", style: titleStyle),
                const SizedBox(height: 5),
                Text(
                  "$totalAmount EGP",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff009f93),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // NAVIGATION BUTTONS
  // =========================================================
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (currentStep > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Color(0xff14B8A6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Back",
                  style: TextStyle(color: Color(0xff14B8A6)),
                ),
              ),
            ),
          if (currentStep > 1) const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (currentStep < 3) {
                  if (currentStep == 2 && cardSelected) {
                    if (_formKey.currentState!.validate()) {
                      setState(() => currentStep++);
                    }
                  } else {
                    setState(() => currentStep++);
                  }
                } else {
                  _confirmAppointment();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff14B8A6),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                currentStep == 3 ? "Confirm" : "Next",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
