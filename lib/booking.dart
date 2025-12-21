import 'package:flutter/material.dart';
import 'package:shifa/patient_home_screen.dart';
import 'package:shifa/Services/firebase_services.dart';

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

  final Color primaryTeal = const Color(0xff14B8A6);
  final Color darkTeal = const Color(0xff009f93);

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

  bool cardSelected = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();

  late String doctorId,
      doctorName,
      doctorSpecialty,
      clinicLocation,
      serviceType,
      totalAmount;
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

  Future<void> _confirmAppointment() async {
    final currentUserId = _firebaseServices.getCurrentUserId();
    if (currentUserId == null) {
      _showErrorDialog("You must be logged in to book an appointment");
      return;
    }
    setState(() => isLoading = true);
    try {
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
        await _firebaseServices.bookTimeSlot(
          doctorId: doctorId,
          date: selectedDate,
          time: selectedTime,
        );
        if (mounted) _showSuccessDialog();
      } else {
        if (mounted) _showErrorDialog("Failed to create appointment.");
      }
    } catch (e) {
      if (mounted) _showErrorDialog("Failed to book: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
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
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
              (route) => false,
            ),
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

  List<DateTime> get dates =>
      List.generate(maxDays, (i) => DateTime.now().add(Duration(days: i)));
  String dayFormat(DateTime date) =>
      ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][date.weekday - 1];
  String dateFormat(DateTime date) => date.day.toString().padLeft(2, '0');

  void centerSelectedDate(DateTime date) {
    int center = displayCount ~/ 2;
    startIndex = dates.indexOf(date) - center;
    if (startIndex < 0) startIndex = 0;
    if (startIndex + displayCount > dates.length) {
      startIndex = dates.length - displayCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
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
          ? Center(child: CircularProgressIndicator(color: primaryTeal))
          : Column(
              children: [
                _buildProgressIndicator(),
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
            color: isActive || isCompleted ? primaryTeal : Colors.grey.shade300,
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
            color: isActive ? primaryTeal : Colors.grey,
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
  // STEP 1: DATE & TIME (Modified Design)
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
        SizedBox(
          height: 95, // تصغير الارتفاع الكلي قليلاً
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () =>
                    startIndex > 0 ? setState(() => startIndex--) : null,
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayCount,
                  itemBuilder: (context, i) {
                    int actualIndex = startIndex + i;
                    if (actualIndex >= dates.length) return const SizedBox();
                    DateTime date = dates[actualIndex];
                    bool isSelected = date.day == selectedDate.day;

                    return GestureDetector(
                      onTap: () => setState(() => selectedDate = date),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: isSelected
                            ? 62
                            : 58, // حجم أصغر قليلاً مع فرق بسيط للمختار
                        margin: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryTeal
                              : const Color(0xffF2F4F7),
                          borderRadius: BorderRadius.circular(14),
                          // إضافة الظل للمختار فقط لجعله بارزاً
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: primaryTeal.withAlpha(80),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayFormat(date),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.grey,
                                fontSize: isSelected ? 13 : 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat(date),
                              style: TextStyle(
                                fontSize: isSelected
                                    ? 22
                                    : 20, // أرقام أصغر وأرق
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
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
                onPressed: () => startIndex + displayCount < dates.length
                    ? setState(() => startIndex++)
                    : null,
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
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: times
              .map((t) => _buildTimeChip(t, t == selectedTime))
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
          color: active ? primaryTeal : const Color(0xffF2F4F7),
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

  Widget _buildPaymentOption({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? primaryTeal : Colors.grey.shade300,
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
                  color: selected ? primaryTeal : Colors.grey,
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

  Widget _buildSummaryStep() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "BOOKING SUMMARY",
            style: TextStyle(
              color: darkTeal,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 18,
            ),
          ),
          const Divider(height: 40, thickness: 1),
          _buildSummaryRow("Doctor", doctorName),
          _buildSummaryRow("Specialty", doctorSpecialty),
          _buildSummaryRow("Clinic", clinicLocation),
          _buildSummaryRow(
            "Date",
            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
          ),
          _buildSummaryRow("Time", selectedTime),
          _buildSummaryRow("Payment", paymentMethod),
          const Divider(height: 40, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "$totalAmount EGP",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryTeal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => currentStep == 1
                  ? Navigator.of(context).pop()
                  : setState(() => currentStep--),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(color: primaryTeal),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text("Back", style: TextStyle(color: primaryTeal)),
            ),
          ),
          const SizedBox(width: 10),
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
                backgroundColor: primaryTeal,
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

  Widget _buildCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 15),
          _buildInputField(
            cardNumberController,
            "0000 0000 0000 0000",
            Icons.credit_card,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  expiryDateController,
                  "MM/YY",
                  Icons.calendar_month,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInputField(
                  cvcController,
                  "CVC",
                  Icons.lock_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryTeal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryTeal, width: 2),
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? "Required" : null,
    );
  }
}
