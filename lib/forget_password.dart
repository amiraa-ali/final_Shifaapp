import 'package:flutter/material.dart';
import 'patient_login.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String password = '';
  String confirmPassword = '';

  String? passwordError;
  String? confirmError;

  bool get hasMinLength => password.length >= 8;
  bool get hasSpecialChar =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);

  void _onResetPassword() {
    setState(() {
      passwordError = null;
      confirmError = null;

      bool valid = true;

      if (password.isEmpty) {
        passwordError = 'Password is required';
        valid = false;
      } else if (!hasMinLength || !hasSpecialChar) {
        passwordError = 'Password does not meet requirements';
        valid = false;
      }

      if (confirmPassword.isEmpty) {
        confirmError = 'Confirm password is required';
        valid = false;
      } else if (confirmPassword != password) {
        confirmError = 'Passwords do not match';
        valid = false;
      }

      if (valid) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PasswordResetSuccessScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false, // المستطيل ثابت
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // الشريط العلوي
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.15,
            child: Container(color: Colors.teal),
          ),

          // البطاقة البيضاء
          Align(
            alignment: Alignment.center,
            child: Container(
              width: size.width * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // أيقونة القفل
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.teal, width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock_open,
                        size: 40,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  const Text(
                    'Set a new password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your new password must be different from previously used passwords',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password Field + Error
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        obscureText: _obscurePassword,
                        onChanged: (val) {
                          setState(() {
                            password = val;
                            passwordError = null;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Password',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.teal.withOpacity(0.1),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      if (passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            passwordError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Confirm Field + Error
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        obscureText: _obscureConfirm,
                        onChanged: (val) {
                          setState(() {
                            confirmPassword = val;
                            confirmError = null;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Confirm password',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.teal.withOpacity(0.1),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              });
                            },
                          ),
                        ),
                      ),
                      if (confirmError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            confirmError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Password Requirements
                  _buildPasswordRequirement(
                    text: 'Must be at least 8 characters',
                    isValid: hasMinLength,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordRequirement(
                    text: 'Must contain one special character',
                    isValid: hasSpecialChar,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 15),

                  // Reset Button
                  SizedBox(
                    height: 50,
                    child: InkWell(
                      onTap: _onResetPassword,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.teal,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Reset password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Back to login
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientLogin(),
                        ),
                      );
                    },
                    child: const Text(
                      '← Back to login',
                      style: TextStyle(color: Colors.teal, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // زر العودة العلوي
          Positioned(
            top: 50,
            left: 24,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirement({
    required String text,
    required bool isValid,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isValid ? color : color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Icon(
            Icons.check,
            size: 14,
            color: isValid ? Colors.white : Colors.transparent,
          ),
        ),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(color: color, fontSize: 14)),
      ],
    );
  }
}

// ========================================================
// صفحة نجاح إعادة تعيين كلمة المرور
// ========================================================
class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  final Color primaryTextColor = const Color(0xff333333);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.15,
            child: Container(color: Colors.teal),
          ),
          Center(
            child: Container(
              width: size.width * 0.85,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.teal, width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.check, size: 50, color: Colors.teal),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Password reset!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You\'ve successfully created a new password, click below to log in',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 50,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PatientLogin(),
                          ),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.teal,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 24,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
