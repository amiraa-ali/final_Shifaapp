import 'package:flutter/material.dart';

class CustomTextForm extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? mycontroller;
  const CustomTextForm({
    super.key,
    this.labelText,
    this.hintText,
    this.mycontroller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: mycontroller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: const Icon(Icons.lock_outline),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.teal),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) return "Password is required";
        if (value.length < 6) return "At least 6 characters";
        return null;
      },
    );
  }
}
